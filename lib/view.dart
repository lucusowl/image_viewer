import 'dart:io';
import 'package:flutter/material.dart';

class ViewPage extends StatefulWidget {
  final String? filePath;
  const ViewPage({super.key, this.filePath});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final double _maxScale = 10.0;
  final double _minScale = 1.0;
  late File? _currentFile;
  final TransformationController _transformController = TransformationController();

  void _zoomReset() {
    _transformController.value = Matrix4.identity();
  }

  /// 2배 확대
  void _zoomIn() {
    if (_transformController.value.getMaxScaleOnAxis() * 2.0 <= _maxScale) {
      _transformController.value = _transformController.value * Matrix4.diagonal3Values(2.0, 2.0, 1.0);
    }
  }

  /// 2배 축소
  void _zoomOut() {
    if (_transformController.value.getMaxScaleOnAxis() * 0.5 >= _minScale) {
      _transformController.value = _transformController.value * Matrix4.diagonal3Values(0.5, 0.5, 1.0);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.filePath == null) {
      _currentFile = null;
    } else {
      _currentFile = File(widget.filePath!).absolute;
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 이미지 메인 화면
        Center(
          child: (_currentFile == null)
          ? Icon(Icons.cancel)
          : InteractiveViewer(
            transformationController: _transformController,
            clipBehavior: .none,
            trackpadScrollCausesScale: true,
            // constrained: false,
            minScale: _minScale,
            maxScale: _maxScale,
            child: Image(
              image: FileImage(_currentFile!),
              loadingBuilder:(context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
              // errorBuilder: (context, error, stackTrace) => const Placeholder(),
            ),
          ),
        ),

        // 이미지 상세 패널
        if (_currentFile != null)
          Align(
            alignment: .bottomCenter,
            child: Container(
              padding: const .symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  Padding(
                    padding: const .all(8.0),
                    child: Text(_currentFile!.path.split(Platform.pathSeparator).last),
                  ),
                  IconButton(onPressed: _zoomReset, icon: Icon(Icons.refresh)),
                  IconButton(onPressed: _zoomIn, icon: Icon(Icons.zoom_in)),
                  IconButton(onPressed: _zoomOut, icon: Icon(Icons.zoom_out)),
                ],
              ),
            )
          ),
      ],
    );
  }
}