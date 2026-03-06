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
  final GlobalKey _viewerKey = GlobalKey();

  /// 화면 초기화
  void _zoomReset() {
    _transformController.value = Matrix4.identity();
  }

  /// 2배 확대
  void _zoomIn() {
    if (!mounted) return;
    if (_transformController.value.getMaxScaleOnAxis() * 2.0 <= _maxScale) {
      final Matrix4 currentMatrix = _transformController.value;

      final Size viewerSize = _viewerKey.currentContext!.size!;
      final Offset viewportCenter = Offset(viewerSize.width / 2, viewerSize.height / 2);
      final Matrix4 invertedMatrix = Matrix4.inverted(currentMatrix);
      final sceneCenter = invertedMatrix.applyToVector3Array([
        viewportCenter.dx, viewportCenter.dy, 0
      ]);

      final Matrix4 newMatrix = currentMatrix.clone()
        ..translateByDouble(sceneCenter[0], sceneCenter[1], 0.0, 1.0)
        ..scaleByDouble(2.0, 2.0, 1.0, 1.0)
        ..translateByDouble(-sceneCenter[0], -sceneCenter[1], 0.0, 1.0);

      _transformController.value = newMatrix;
    }
  }

  /// 2배 축소
  void _zoomOut() {
    if (!mounted) return;
    if (_transformController.value.getMaxScaleOnAxis() * 0.5 >= _minScale) {
      final Matrix4 currentMatrix = _transformController.value;

      final Size viewerSize = _viewerKey.currentContext!.size!;
      final Offset viewportCenter = Offset(viewerSize.width / 2, viewerSize.height / 2);
      final Matrix4 invertedMatrix = Matrix4.inverted(currentMatrix);
      final sceneCenter = invertedMatrix.applyToVector3Array([
        viewportCenter.dx, viewportCenter.dy, 0
      ]);

      final Matrix4 newMatrix = currentMatrix.clone()
        ..translateByDouble(sceneCenter[0], sceneCenter[1], 0.0, 1.0)
        ..scaleByDouble(0.5, 0.5, 1.0, 1.0)
        ..translateByDouble(-sceneCenter[0], -sceneCenter[1], 0.0, 1.0);

      _transformController.value = newMatrix;
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
        _zoomReset(); // 새로 열때 화면 상태 초기화
        final fileModel = FileModelProvider.of(context);
        return Stack(
          children: [
            // 이미지 메인 화면
            Center(
              child: (fileModel.file == null)
              ? ErrorTile(errorCode: fileModel.errorCode ?? ErrorCode.unknown)
              : InteractiveViewer(
                key: _viewerKey,
                transformationController: _transformController,
                clipBehavior: .none, // 확대하여도 viewport를 벗어나는 부분이 clop되지 않게
                trackpadScrollCausesScale: true, // 노트북을 사용하는 경우
                // boundaryMargin: EdgeInsets.all(double.infinity),
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
                  padding: const .symmetric(vertical: 16),
                  decoration: BoxDecoration(color: Colors.black54),
                  child: Row(
                    mainAxisAlignment: .center,
                    children: [
                      Padding(
                        padding: const .all(8.0),
                        child: Text(fileModel.file!.path.split(Platform.pathSeparator).last),
                      ),
                      IconButton(onPressed: _zoomReset, icon: Icon(Icons.fit_screen), tooltip: "화면 초기화",),
                      IconButton(onPressed: _zoomIn, icon: Icon(Icons.zoom_in), tooltip: "2배 확대"),
                      IconButton(onPressed: _zoomOut, icon: Icon(Icons.zoom_out), tooltip: "2배 축소"),
                      IconButton(onPressed: fileModel.pickFile, icon: Icon(Icons.file_open), tooltip: "새 파일 열기"),
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