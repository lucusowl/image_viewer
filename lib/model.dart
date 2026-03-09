import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_viewer/error_tile.dart';

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

  /// `FileModel`의 현재 파일을 반환, 없을 경우 null
  File? get file => _currentFile;
  /// `FileModel`의 현재 에러코드를 반환, 없을 경우 null
  ErrorCode? get errorCode => _errorCode;
  /// `FileModel`의 현재 파일이 파일 목록의 1번째인지 여부를 반환
  bool get isFirst => (_currentIndex == 0);
  /// `FileModel`의 현재 파일이 파일 목록의 마지막인지 여부를 반환
  bool get isLast => (_currentIndex == _currentFileList.length-1);

  /// 현재 파일을 갱신
  /// 재빌드 요청없이 진행용도로 사용할 것. (최초 빌드)
  /// 이미 설정된 파일이 있을 경우 무시됨.
  void initFile(String? path) {
    if (_currentFile != null) return;
    if (path == null) {
      _currentFile = null;
      _errorCode = ErrorCode.noPath;
    } else {
      _currentFile = File(path).absolute;
      _errorCode = null;
      updateCurrentFileList();
    }
  }

  /// 현재 파일을 갱신
  void updateFile(String path) {
    _currentFile = File(path).absolute;
    _errorCode = null;
    notifyListeners();
    updateCurrentFileList();
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
    updateFile(file.path);
    return true;
  }

  /// 파일 목록 갱신
  /// 비동기로 파일이 있는 폴더와 파일 목록을 갱신.
  Future<void> updateCurrentFileList() async {
    _currentDirectory = _currentFile!.parent;
    /// 파일목록 초기화
    _currentFileList.clear();
    _currentIndex = -1;

    int tempIndex = 0;
    _currentDirectory!.list().listen((FileSystemEntity entity) {
      // 파일이고 이미지확장자를 가진 경우 => 파일목록에 추가
      if (entity is! File) return; // 파일이 아닌 경우 무시
      String entityPath = entity.path;
      int dotIndex = entityPath.lastIndexOf('.');
      if (dotIndex == -1) return; // 확장자가 없는 경우 무시
      String entityExtension = entityPath.substring(dotIndex+1).toLowerCase();
      if (_imageExtensions.contains(entityExtension)) {
        _currentFileList.add(entity.absolute);
        if (entity.path == _currentFile!.path) {_currentIndex = tempIndex;}
        tempIndex++;
      }
    });
  }

  /// 이전 파일로 갱신
  bool previousFile() {
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
    if (_currentIndex < _currentFileList.length-1) {
      _currentIndex++;
      _currentFile = _currentFileList[_currentIndex];
      notifyListeners();
      return true;
    } else {
      return false;
    }
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