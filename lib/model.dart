import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_viewer/error_tile.dart';
import 'package:image_viewer/snackbar.dart';

/// 파일 관리 객체
/// `_errorCode`, `_currentFile`를 변경한 경우 `notifyListeners()`를 호출할 것
class FileModel with ChangeNotifier {
  /// `FileModel`이 불러올 수 있는 이미지파일 확장자
  final List<String> _imageExtensions = const ["jpg", "jpeg", "png", "gif", "webp", "bmp", "wbmp", "ico", "cur"];
  List<XTypeGroup> get _acceptedTypeGroups => [
    // 허용된 이미지 파일 그룹
    XTypeGroup(
      label: "Images",
      extensions: _imageExtensions,
      mimeTypes: ["image/*"]
    ),
    // 모든 파일 그룹
    XTypeGroup(label: "All Files"),
  ];

  /// 현재 파일
  File? _currentFile;
  /// 현재 파일이 있는 디렉토리
  Directory? _currentDirectory;
  /// 파일 목록
  final List<File> _currentFileList = [];
  /// 파일 목록에서 현재 파일의 index
  /// -1일 경우 파일 없음을 나타냄
  int _currentIndex = -1;

  /// 에러 코드
  ErrorCode? _errorCode;

  /// `FileModel`의 현재 에러코드를 반환, 없을 경우 null
  ErrorCode? get errorCode => _errorCode;
  /// `FileModel`의 현재 파일을 반환, 없을 경우 null
  File? get file => _currentFile;
  /// `FileModel`의 현재 파일이름을 반환, 없을 경우 null
  String? get fileName => _currentFile?.path.split(Platform.pathSeparator).last;
  /// `FileModel`의 현재 파일이 파일 목록의 1번째인지 여부를 반환
  bool get isFirst => (_currentIndex == -1 || _currentIndex == 0);
  /// `FileModel`의 현재 파일이 파일 목록의 마지막인지 여부를 반환
  bool get isLast => (_currentIndex == -1 || _currentIndex == _currentFileList.length-1);

  /// 현재 파일을 갱신
  ///
  /// 재빌드 요청없이 진행용도로 사용할 것. (최초 빌드)
  /// 이미 설정된 파일이 있을 경우 무시됨.
  void initFile(String? path) {
    if (_currentFile != null) return;
    if (path == null) {
      _currentFile = null;
      _currentDirectory = null;
      _errorCode = ErrorCode.noPath;
    } else {
      _currentFile = File(path).absolute;
      _currentDirectory = _currentFile!.parent;
      _errorCode = null;

      updateCurrentFileList(onSuccess: () {
        int tempIndex = 0;
        for (File file in _currentFileList) {
          if (file.path == _currentFile!.path) {
            _currentIndex = tempIndex;
            break;
          }
          tempIndex++;
        }
      });
    }
  }

  /// 갱신할 파일을 선택
  ///
  /// 갱신할 파일이 선택되지 않은 경우 false가 반환되며 갱신이 이루어지지 않음.
  Future<bool> pickFile() async {
    final XFile? file = await openFile(acceptedTypeGroups: _acceptedTypeGroups);
    if (file == null) return false;

    // 캐시 비우기
    final ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear(); // 모든 캐시 해제
    imageCache.clearLiveImages(); // 화면에 표시된 캐시참조도 해제

    _currentFile = File(file.path).absolute;
    _currentDirectory = _currentFile!.parent;
    _errorCode = null;

    notifyListeners();

    updateCurrentFileList(onSuccess: () {
      int tempIndex = 0;
      for (File file in _currentFileList) {
        if (file.path == _currentFile!.path) {
          _currentIndex = tempIndex;
          break;
        }
        tempIndex++;
      }
    });
    return true;
  }

  /// 갱신할 폴더 선택
  ///
  /// 갱신할 폴더가 선택되지 않은 경우 false가 반환되며 갱신이 이루어지지 않음.
  Future<bool> pickDirectory() async {
    final String? path = await getDirectoryPath();
    if (path == null) return false;

    // 캐시 비우기
    final ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear(); // 모든 캐시 해제
    imageCache.clearLiveImages(); // 화면에 표시된 캐시참조도 해제

    _currentDirectory = Directory(path).absolute;
    // 표시할 파일을 찾고 있음을 화면에 표시
    _currentFile = null;
    _errorCode = null;

    notifyListeners();

    updateCurrentFileList(onSuccess: () {
      // 적합한 파일이 없는 폴더의 경우
      if (_currentFileList.isEmpty) {
        _errorCode = ErrorCode.noFile;
      } else {
        _currentIndex = 0;
        _currentFile = _currentFileList[0];
      }
      notifyListeners();
    });
    return true;
  }

  /// 파일 목록 변경 알림자
  final ValueNotifier<bool> _isReadyFileList = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isReadyFileList => _isReadyFileList;
  /// 파일 목록 갱신
  ///
  /// 비동기로 파일이 있는 폴더와 파일 목록을 갱신.
  /// - [onSuccess]: 갱신을 성공적으로 완료한 이후 callback
  /// - [onError]: 갱신 도중 에러가 발생한 이루 callback, 에러객체 인자 전달됨
  Future<void> updateCurrentFileList({void Function()? onSuccess, void Function(Object)? onError}) async {
    /// 파일목록 초기화
    _currentFileList.clear();
    _currentIndex = -1;
    _isReadyFileList.value = false;

    _currentDirectory!.list().listen((FileSystemEntity entity) {
      // 파일이고 이미지확장자를 가진 경우 => 파일목록에 추가
      if (entity is! File) return; // 파일이 아닌 경우 무시
      String entityPath = entity.path;
      int dotIndex = entityPath.lastIndexOf('.');
      if (dotIndex == -1) return; // 확장자가 없는 경우 무시
      String entityExtension = entityPath.substring(dotIndex+1).toLowerCase();
      if (_imageExtensions.contains(entityExtension)) {
        _currentFileList.add(entity.absolute);
      }
    },
    onDone: () {
      // 파일명으로 오름차순 정렬
      _currentFileList.sort((File f1, File f2) => f1.path.toLowerCase().compareTo(f2.path.toLowerCase()));
      if (onSuccess != null) onSuccess();
      _isReadyFileList.value = true;
    },
    onError: (Object error) {
      /// 갱신 도중 문제가 발생 알림, ErrorCode.errorLoadFiles
      GlobalSnackbar.showError("목록 갱신 오류 발생");
      if (onError != null) onError(error);
      _isReadyFileList.value = false;
    });
  }

  /// 현재 이미지캐시를 다른 이름 파일로 저장
  ///
  /// 파일을 복사하는 방식이 아닌 캐시에 디코딩된 데이터를 파일로 저장하는 방식.
  /// 때문에 파일을 삭제또는 변경 후 캐시에 있는 파일데이터 복원하는 용도로 활용가능.
  Future<bool> saveAsFile() async {
    /// 유효성 검사
    /// 현재 파일이 지정되어 있는지 확인
    if (_currentFile == null) return false;

    /// 저장할 파일 경로 받아오기
    /// 권장파일명 뒤에 '-copy'추가, 확장자는 기본 '.png'
    final String suggestedName = fileName!.replaceRange(fileName!.lastIndexOf('.'), null, '-copy.png');
    final FileSaveLocation? savePath = await getSaveLocation(
      acceptedTypeGroups: _acceptedTypeGroups,
      initialDirectory: _currentDirectory?.path ?? Directory.current.path,
      suggestedName: suggestedName);
    if (savePath == null) return false;

    /// 저장 시작 알림, (용량이 큰 파일일 경우 오래 걸림)
    GlobalSnackbar.show("저장 중");
    try {
      /// ImageProvider로부터 이미지로드 스트림 생성
      final ImageStream stream = FileImage(_currentFile!).resolve(.empty);
      final Completer<ui.Image> completer = Completer<ui.Image>();

      late ImageStreamListener listener;
      listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
        stream.removeListener(listener);
      });
      stream.addListener(listener);
      final ui.Image image = await completer.future;

      /// png 포멧으로 파일을 저장
      /// 무손실 포멧, 디코딩된 캐시데이터를 그대로 파일로 저장
      ByteData? byteData = await image.toByteData(format: .png);
      if (byteData == null) return false;
      await File(savePath.path).writeAsBytes(byteData.buffer.asUint8List());
      /// 저장이 완료 알림
      GlobalSnackbar.show("저장 완료");
      return true;
    } catch (e) {
      /// 저장 도중 문제가 발생 알림
      GlobalSnackbar.showError("${savePath.path} 저장 오류");
      return false;
    }
  }

  /// 목록에서 제거 유효성 검사
  bool isNotValidToRemoveFileFromCurrentFileList() {
    return (_currentFile == null);
  }
  /// 현재 파일을 파일 목록에서 제거
  bool removeFileFromCurrentFileList() {
    /// 캐시 삭제
    FileImage(_currentFile!).evict().catchError((e,s) {
      GlobalSnackbar.showError("캐시 삭제 불가");
      return false;
    });

    /// 현 파일 갱신 및 목록에서 삭제
    final int lengthOfFileList = _currentFileList.length;
    if (lengthOfFileList == 1) {
      /// 파일목록에 삭제할 파일만 있을 경우 => 파일없음 알림
      _currentFileList.removeAt(_currentIndex);
      _currentIndex = -1;
      _currentFile = null;
      _errorCode = .noFile;
    } else {
      if (lengthOfFileList == _currentIndex + 1) {
        /// 맨 뒤에 해당할 경우
        _currentFile = _currentFileList[_currentIndex-1];
        _currentFileList.removeAt(_currentIndex);
        _currentIndex--;
      } else {
        /// 그 외
        _currentFile = _currentFileList[_currentIndex+1];
        _currentFileList.removeAt(_currentIndex);
      }
    }
    notifyListeners();
    return true;
  }

  /// 삭제 유효성 검사
  bool isNotValidToDeleteFile() {
    return (_currentFile == null);
  }
  /// 현재 파일을 삭제
  Future<bool> deleteFile() async {
    try {
      /// 파일 삭제
      await _currentFile?.delete(); // 영구삭제
      /// 현재 파일을 목록에서 제외
      return removeFileFromCurrentFileList();
    } catch (e) {
      /// 제거 도중 문제가 발생 알림
      GlobalSnackbar.showError("파일 삭제 오류");
      return false;
    }
  }

  /// 이전 파일로 갱신
  bool previousFile() {
    if (_currentIndex == -1) return false;
    if (_currentIndex > 0) {
      _currentIndex--;
      _currentFile = _currentFileList[_currentIndex];
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
  /// 다음 파일로 갱신
  bool nextFile() {
    if (_currentIndex == -1) return false;
    if (_currentIndex < _currentFileList.length-1) {
      _currentIndex++;
      _currentFile = _currentFileList[_currentIndex];
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  /// 파일 탐색기로 열기
  bool openFileByExplorer() {
    // 유효성 검사
    if (_currentFile == null) return false;

    Process.start("explorer.exe", ["/select,", _currentFile!.path], mode: .detached)
    // .then((process){GlobalSnackbar.show("파일 탐색기 열기 실행완료");})
    .catchError((e) {
      GlobalSnackbar.showError("파일 탐색기 열기 실패");
    });
    return true;
  }

  /// 그림판으로 열기
  bool openFileByMSPaint() {
    // 유효성 검사
    if (_currentFile == null) return false;

    Process.start("mspaint.exe", [_currentFile!.path], mode: .detached)
    // .then((process){GlobalSnackbar.show("그림판 열기 실행완료");})
    .catchError((e) {
      GlobalSnackbar.showError("그림판 열기 실패");
    });
    return true;
  }

  @override
  void dispose() {
    _isReadyFileList.dispose();
    super.dispose();
  }
}

class FileModelProvider extends InheritedWidget {
  final FileModel model;
  const FileModelProvider({super.key, required this.model, required super.child});

  static FileModelProvider? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<FileModelProvider>();

  static FileModelProvider of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No FileModelProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}