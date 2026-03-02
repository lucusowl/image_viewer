import 'dart:io';
import 'package:flutter/material.dart';

class ViewPage extends StatefulWidget {
  final String? filePath;
  const ViewPage({super.key, this.filePath});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  late File? _currentFile;
  final TransformationController _transformController = TransformationController();

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override void initState() {
    super.initState();
    if (widget.filePath == null) {
      _currentFile = null;
    } else {
      _currentFile = File(widget.filePath!).absolute;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: (_currentFile == null)
          ? Icon(Icons.cancel)
          : InteractiveViewer(
            transformationController: _transformController,
            clipBehavior: .none,
            trackpadScrollCausesScale: true,
            // boundaryMargin: .all(64),
            // constrained: false,
            minScale: 1.0,
            maxScale: 10.0,
            child: Image(
              image: FileImage(_currentFile!),
              loadingBuilder:(context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),

        // 파일 이름 영역
        Positioned(
          child: Container(
            padding: const .all(8.0),
            child: (_currentFile == null)
              ? Text("NOT FOUND")
              : Text(_currentFile!.path.split(Platform.pathSeparator).last)
          ),
        ),

        // 이미지 행동 나열
        if (_currentFile != null)
          Align(
            alignment: .centerRight,
            child: Container(
              padding: const .symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  IconButton(onPressed: _resetZoom, icon: Icon(Icons.refresh)),
                ],
              ),
            )
          ),
      ],
    );
  }
}