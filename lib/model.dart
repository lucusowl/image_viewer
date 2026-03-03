import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_viewer/error_tile.dart';

class FileModel with ChangeNotifier {
  File? _currentFile;
  ErrorCode? _errorCode;

  File? get file => _currentFile;
  ErrorCode? get errorCode => _errorCode;

  void initFile(String? path) {
    if (path == null) {
      _currentFile = null;
      _errorCode = ErrorCode.noPath;
    } else {
      _currentFile = File(path).absolute;
      _errorCode = null;
    }
  }

  void updateFile(String path) {
    _currentFile = File(path).absolute;
    notifyListeners();
  }

  Future<bool> pickFile() async {
    // 허용된 이미지 파일그룹
    const XTypeGroup imageTypeGroup = XTypeGroup(
      label: "Images",
      extensions: ["jpg", "jpeg", "png", "gif", "webp", "bmp", "wbmp", "ico", "cur"],
      mimeTypes: ["image/*"]
    );
    // 모든 파일 그룹
    const XTypeGroup allTypeGroup = XTypeGroup(label: "All Files");

    final XFile? file = await openFile(acceptedTypeGroups: [imageTypeGroup, allTypeGroup]);

    if (file == null) return false;
    updateFile(file.path);
    return true;
  }
}

class FileModelProvider extends InheritedWidget {
  final FileModel model;
  const FileModelProvider({super.key, required this.model, required super.child});

  static FileModel of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<FileModelProvider>()!.model;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}