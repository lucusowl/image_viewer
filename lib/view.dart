import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_viewer/error_tile.dart';
import 'package:image_viewer/model.dart';

class ViewPageWrapper extends StatefulWidget {
  final String? filePath;
  const ViewPageWrapper({super.key, this.filePath});

  @override
  State<ViewPageWrapper> createState() => _ViewPageWrapperState();
}

class _ViewPageWrapperState extends State<ViewPageWrapper> {
  final FileModel _model = FileModel();

  @override
  void initState() {
    super.initState();
    _model.initFile(widget.filePath);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FileModelProvider(
      model: _model,
      child: ViewPage(filePath: widget.filePath)
    );
  }
}

class ViewPage extends StatefulWidget {
  final String? filePath;
  const ViewPage({super.key, this.filePath});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final double _maxScale = 10.0;
  final double _minScale = 1.0;
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
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FileModelProvider.of(context),
      builder: (context, child) {
        final fileModel = FileModelProvider.of(context);
        return Stack(
          children: [
            // 이미지 메인 화면
            Center(
              child: (fileModel.file == null)
              ? ErrorTile(errorCode: fileModel.errorCode ?? ErrorCode.unknown)
              : InteractiveViewer(
                transformationController: _transformController,
                clipBehavior: .none,
                trackpadScrollCausesScale: true,
                // constrained: false,
                minScale: _minScale,
                maxScale: _maxScale,
                child: Image(
                  image: FileImage(fileModel.file!),
                  loadingBuilder:(context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) => ErrorTile(
                    errorCode: ErrorCode.errorLoadImage,
                    errorMessage: "${error.toString()}\n\n${stackTrace.toString()}",
                  ),
                ),
              ),
            ),
        
            // 이미지 상세 패널
            if (fileModel.file != null)
              Align(
                alignment: .bottomCenter,
                child: Container(
                  padding: const .symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: .center,
                    children: [
                      Padding(
                        padding: const .all(8.0),
                        child: Text(fileModel.file!.path.split(Platform.pathSeparator).last),
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
      },
    );
  }
}