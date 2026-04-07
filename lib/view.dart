import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_viewer/error_tile.dart';
import 'package:image_viewer/model.dart';
import 'package:image_viewer/shortcut.dart';
import 'package:image_viewer/viewer_action_overlay.dart';

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
  final ValueNotifier<bool> _isFocusMode = ValueNotifier<bool>(false);
  final ValueNotifier<MouseCursor> _cursorNotifier = ValueNotifier<MouseCursor>(SystemMouseCursors.none);
  Timer? _hideTimer;

  /// 화면 초기화 기능
  void _zoomReset() {
    // _transformController 가 적용된 이후에만 동작
    if (!mounted) return;
    _transformController.value = Matrix4.identity();
  }

  /// 화면 zoom 기능
  void _zoomByScale(double targetScale) {
    // _transformController 가 적용된 이후에만 동작
    if (!mounted) return;
    final Matrix4 currentMatrix = _transformController.value;

    final Size? viewerSize = _viewerKey.currentContext?.size;
    if (viewerSize == null) return;
    final Offset viewportCenter = Offset(viewerSize.width / 2, viewerSize.height / 2);
    final Matrix4 invertedMatrix = Matrix4.inverted(currentMatrix);
    final sceneCenter = invertedMatrix.applyToVector3Array([
      viewportCenter.dx, viewportCenter.dy, 0
    ]);

    final Matrix4 newMatrix = currentMatrix.clone()
      ..translateByDouble(sceneCenter[0], sceneCenter[1], 0.0, 1.0)
      ..scaleByDouble(targetScale, targetScale, targetScale, 1.0)
      ..translateByDouble(-sceneCenter[0], -sceneCenter[1], 0.0, 1.0);

    _transformController.value = newMatrix;
  }

  /// 2배 확대
  void _zoomIn() {
    // _transformController 가 적용된 이후에만 동작
    if (!mounted) return;
    const double targetScale = 2.0;
    final double currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale >= _maxScale) return;
    if (currentScale * targetScale <= _maxScale) {
      _zoomByScale(targetScale);
    } else {
      _zoomByScale(_maxScale / currentScale);
    }
  }

  /// 2배 축소
  void _zoomOut() {
    // _transformController 가 적용된 이후에만 동작
    if (!mounted) return;
    const double targetScale = 0.5;
    final double currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale <= _minScale) return;
    if (currentScale * targetScale >= _minScale) {
      _zoomByScale(targetScale);
    } else {
      _zoomByScale(_minScale / currentScale);
    }
  }

  /// 화면 집중 모드 토글 기능
  void _toggleFocusMode() {
    _isFocusMode.value = !_isFocusMode.value;
  }

  /// 마우스 움직일 때 커서보이게 기능
  void _onMouseHover(_) {
    _cursorNotifier.value = MouseCursor.defer; // 커서 보이게
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 1), () {
      _cursorNotifier.value = SystemMouseCursors.none; // 커서 안보이게
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    _isFocusMode.dispose();
    _cursorNotifier.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = FileModelProvider.of(context).model;
    return ViewPageShortcutWrapper(
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenNewFileIntent: OpenNewFileAction(model),
          OpenNewDirectoryIntent: OpenNewDirectoryAction(model),
          OpenFileByExplorerIntent: OpenFileByExplorerAction(model),
          OpenFileByMSPaintIntent: OpenFileByMSPaintAction(model),
          MoveToPreviousFileIntent: MoveToPreviousFileAction(model),
          MoveToNextFileIntent: MoveToNextFileAction(model),
          SaveAsFileIntent: SaveAsFileAction(model),
          DeleteFileIntent: DeleteFileAction(model),
          RemoveFileInListIntent: RemoveFileInListAction(model),
          ResetViewerIntent: ResetViewerAction(_zoomReset),
          ZoomInViewerIntent: ZoomInViewerAction(_zoomIn),
          ZoomOutViewerIntent: ZoomOutViewerAction(_zoomOut),
          FocusViewerIntent: FocusViewerAction(_toggleFocusMode),
        },
        child: Focus(
          autofocus: true,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isFocusMode,
            builder: (_, bool isFocus, Widget? mainViewer) {
              return Stack(
                children: [
                  // 이미지 메인 화면
                  (isFocus)
                    // 집중모드일 경우
                    ? ValueListenableBuilder<MouseCursor>(
                      valueListenable: _cursorNotifier,
                      builder: (_, MouseCursor currentCursor, _) {
                        return MouseRegion(
                          cursor: currentCursor,
                          onHover: _onMouseHover,
                          onExit: (_) => _hideTimer?.cancel(),
                          child: mainViewer!
                        );
                      },
                    )
                    // 집중모드가 아닐 경우
                    : mainViewer!,
                  // 화면 오버레이
                  // 상태만 유지, 애니메이션,공간점유은 해제
                  Visibility(
                    visible: !isFocus, // 집중 모드 => 보이지 않게
                    maintainState: true,
                    child: const ViewerActionOverlay(),
                  ),
                ],
              );
            },
            child: RepaintBoundary(
              child: GestureDetector(
                onTap: _toggleFocusMode,
                child: LayoutBuilder(
                  builder: (_, BoxConstraints constraints) => InteractiveViewer(
                    key: _viewerKey,
                    transformationController: _transformController,
                    trackpadScrollCausesScale: true,
                    // Viewer 크기를 화면크기에 맞춤
                    constrained: false,
                    // 화면크기만큼 여백
                    boundaryMargin: .symmetric(horizontal: constraints.maxWidth, vertical: constraints.maxHeight),
                    minScale: _minScale,
                    maxScale: _maxScale,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: ListenableBuilder(
                        listenable: model,
                        builder: (BuildContext context, _) {
                          final fileModel = FileModelProvider.of(context).model;
                          // 새 이미지로 전환할 때마다 화면상태 초기화
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _zoomReset();
                          });
                          if (fileModel.file == null) {
                            if (fileModel.errorCode == null) {
                              return const Center(child: CircularProgressIndicator());
                            } else {
                              return ErrorTile(errorCode: fileModel.errorCode!);
                            }
                          } else {
                            return Image(
                              image: FileImage(fileModel.file!),
                              loadingBuilder:(context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator();
                              },
                              errorBuilder: (context, error, stackTrace) {
                                /// TODO: View에서 로직분리 필요
                                /// TODO: model._errorCode 재설정 필요
                                /// 이미 불러온 목록에 대해 각각의 파일의 에러처리
                                final String errorMessage = error.toString();
                                debugPrint(errorMessage);
                                /// 파일이 없는 경우
                                if (error.runtimeType == PathNotFoundException) {
                                  return ErrorTile(
                                    errorCode: ErrorCode.noFile,
                                    errorMessage: "$errorMessage\n\n${stackTrace.toString()}",
                                  );
                                }
                                /// 이미지 파일이 아닌 경우
                                else if (errorMessage.contains("Invalid image data")) {
                                  return ErrorTile(
                                    errorCode: ErrorCode.notImage,
                                    errorMessage: "$errorMessage\n\n${stackTrace.toString()}",
                                  );
                                }
                                /// 그 이외 오류의 경우
                                return ErrorTile(
                                  errorCode: ErrorCode.errorLoadImage,
                                  errorMessage: "$errorMessage\n\n${stackTrace.toString()}",
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}