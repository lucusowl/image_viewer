import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_viewer/error_tile.dart';

/// 파일 관리 객체
/// `_errorCode`, `_currentFile`를 변경한 경우 `notifyListeners()`를 호출할 것
class FileModel with ChangeNotifier {
  /// `FileModel`이 불러올 수 있는 이미지파일 확장자
  final List<String> _imageExtensions = const ["jpg", "jpeg", "png", "gif", "webp", "bmp", "wbmp", "ico", "cur"];

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

      updateCurrentFileList(() {
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
  /// 갱신할 파일이 선택되지 않은 경우 false가 반환되며 갱신이 이루어지지 않음.
  Future<bool> pickFile() async {
    // 허용된 이미지 파일그룹
    XTypeGroup imageTypeGroup = XTypeGroup(
      label: "Images",
      extensions: _imageExtensions,
      mimeTypes: ["image/*"]
    );
    // 모든 파일 그룹
    const XTypeGroup allTypeGroup = XTypeGroup(label: "All Files");

    final XFile? file = await openFile(acceptedTypeGroups: [imageTypeGroup, allTypeGroup]);
    if (file == null) return false;

    _currentFile = File(file.path).absolute;
    _currentDirectory = _currentFile!.parent;
    _errorCode = null;
    notifyListeners();

    updateCurrentFileList(() {
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
  /// 갱신할 폴더가 선택되지 않은 경우 false가 반환되며 갱신이 이루어지지 않음.
  Future<bool> pickDirectory() async {
    final String? path = await getDirectoryPath();
    if (path == null) return false;

    _currentDirectory = Directory(path).absolute;
    _currentFile = null;
    _errorCode = null;
    notifyListeners();

    updateCurrentFileList(() {
      // 적합한 파일이 없는 폴더의 경우
      if (_currentFileList.isEmpty) {
        _errorCode = ErrorCode.noFile;
      } else {
        _currentIndex = 0;
        _currentFile = _currentFileList[0];
        notifyListeners();
      }
    });
    return true;
  }

  /// 파일 목록 변경 알림자
  final ValueNotifier<bool> _isReadyFileList = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isReadyFileList => _isReadyFileList;
  /// 파일 목록 갱신.
  /// 비동기로 파일이 있는 폴더와 파일 목록을 갱신.
  Future<void> updateCurrentFileList(void Function() onSuccess) async {
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
      onSuccess();
      _isReadyFileList.value = true;
    },
    onError: (_) {
      _errorCode = ErrorCode.errorLoadFiles;
      _isReadyFileList.value = false;
    });
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

/// Windows 네이티브 코드 연결 객체
/// 상세한 코드는 `/windows/runner/flutter_window.cpp`를 확인
class WindowController {
  static final platform = MethodChannel('com.example.app/window_control');

  /// Window 창의 FullScreen을 토글
  static void toggleFullscreen() {
    try {
      platform.invokeMethod('toggleFullScreen').onError((e, s) {
        debugPrint("Failed to toggle fullscreen: $e");
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to toggle fullscreen: ${e.message}");
    }
  }
}