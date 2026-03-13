import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_viewer/error_tile.dart';
import 'package:image_viewer/model.dart';
import 'package:image_viewer/shortcut.dart';

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

  /// 화면 초기화 기능
  void _zoomReset() {
    _transformController.value = Matrix4.identity();
  }

  /// 화면 zoom 기능
  void _zoomByScale(double targetScale) {
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
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0)
      ..translateByDouble(-sceneCenter[0], -sceneCenter[1], 0.0, 1.0);

    _transformController.value = newMatrix;
  }

  /// 2배 확대
  void _zoomIn() {
    if (!mounted) return;
    const double targetScale = 2.0;
    if (_transformController.value.getMaxScaleOnAxis() * targetScale <= _maxScale) {
      _zoomByScale(targetScale);
    }
  }

  /// 2배 축소
  void _zoomOut() {
    if (!mounted) return;
    const double targetScale = 0.5;
    if (_transformController.value.getMaxScaleOnAxis() * targetScale >= _minScale) {
      _zoomByScale(targetScale);
    }
  }

  /// 화면 집중 모드 토글 기능
  void _toggleFocusMode() {
    _isFocusMode.value = !_isFocusMode.value;
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = FileModelProvider.of(context).model;
    return ViewPageShortcutWrapper(
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenNewFileIntent: OpenNewFileAction(model),
          MoveToPreviousFileIntent: MoveToPreviousFileAction(model),
          MoveToNextFileIntent: MoveToNextFileAction(model),
          ResetViewerIntent: ResetViewerAction(_zoomReset),
          ZoomInViewerIntent: ZoomInViewerAction(_zoomIn),
          ZoomOutViewerIntent: ZoomOutViewerAction(_zoomOut),
          FocusViewerIntent: FocusViewerAction(_toggleFocusMode),
        },
        child: Focus(
          autofocus: true,
          child: ListenableBuilder(
            listenable: model,
            builder: (BuildContext context, Widget? child) {
              final fileModel = FileModelProvider.of(context).model;
              _zoomReset(); // 새로 열 때마다 화면 상태 초기화
              if (fileModel.file == null) {
                return Center(child: ErrorTile(errorCode: fileModel.errorCode ?? ErrorCode.unknown));
              } else {
                return Stack(
                  children: [
                    // 이미지 메인 화면
                    RepaintBoundary(
                      child: Center(
                        child: InteractiveViewer(
                          key: _viewerKey,
                          transformationController: _transformController,
                          clipBehavior: .none, // 확대하여도 viewport를 벗어나는 부분이 clop되지 않게
                          trackpadScrollCausesScale: true, // 노트북을 사용하는 경우
                          // boundaryMargin: .all(double.infinity), // viewport 벗어나서 pan 가능하게
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
                    ),
    // 집중 모드일 경우 위젯에서 제외
    ValueListenableBuilder<bool>(
      valueListenable: _isFocusMode,
      builder: (_, isFocus, _) {
        return Visibility(
          visible: !isFocus,
          maintainState: true,
          // maintainAnimation: false,
          // maintainSize: false,
          child: Stack(
            children: [
                    // 이전 파일 이동 버튼
                    if (!fileModel.isFirst)
                      Align(
                        alignment: .centerLeft,
                        child: Padding(
                          padding: const .symmetric(horizontal: 16),
                          child: IconButton(onPressed: Actions.handler<MoveToPreviousFileIntent>(context, MoveToPreviousFileIntent()), icon: const Icon(Icons.arrow_back), tooltip: "이전",),
                        )
                      ),
                    // 다음 파일 이동 버튼
                    if (!fileModel.isLast)
                      Align(
                        alignment: .centerRight,
                        child: Padding(
                          padding: const .symmetric(horizontal: 16),
                          child: IconButton(onPressed: Actions.handler<MoveToNextFileIntent>(context, MoveToNextFileIntent()), icon: const Icon(Icons.arrow_forward), tooltip: "다음",),
                        )
                      ),

                    // 이미지 상세 패널
                    Align(
                      alignment: .bottomCenter,
                      child: Container(
                        padding: const .symmetric(vertical: 16),
                        decoration: const BoxDecoration(color: Colors.black54),
                        child: Row(
                          mainAxisAlignment: .center,
                          children: [
                            Padding(
                              padding: const .all(8.0),
                              child: Text(fileModel.file?.path.split(Platform.pathSeparator).last ?? "파일 없음"),
                            ),
                            IconButton(onPressed: Actions.handler<ResetViewerIntent>(context, ResetViewerIntent()), icon: const Icon(Icons.fit_screen), tooltip: "화면 초기화 (space)",),
                            IconButton(onPressed: Actions.handler<ZoomInViewerIntent>(context, ZoomInViewerIntent()), icon: const Icon(Icons.zoom_in), tooltip: "2배 확대 (+)"),
                            IconButton(onPressed: Actions.handler<ZoomOutViewerIntent>(context, ZoomOutViewerIntent()), icon: const Icon(Icons.zoom_out), tooltip: "2배 축소 (-)"),
                            MenuAnchor(
                              menuChildren: [
                                MenuItemButton(
                                  onPressed: Actions.handler<OpenNewFileIntent>(context, OpenNewFileIntent()),
                                  shortcut: const SingleActivator(LogicalKeyboardKey.keyO, control: true),
                                  leadingIcon: const Icon(Icons.file_open, size: 18.0),
                                  child: const Text("새 파일 열기"),
                                ),
                                const Divider(),
                                MenuItemButton(
                                  onPressed: Actions.handler<FocusViewerIntent>(context, FocusViewerIntent()),
                                  shortcut: const SingleActivator(LogicalKeyboardKey.keyT),
                                  leadingIcon: const Icon(Icons.image, size: 18.0),
                                  child: const Text("집중 모드"),
                                ),
                              ],
                              builder: (BuildContext context, MenuController controller, Widget? child) {
                                return IconButton(
                                  onPressed: () {
                                    if (controller.isOpen) {controller.close();}
                                    else {controller.open();}
                                  },
                                  icon: const Icon(Icons.more_vert),
                                  tooltip: "더보기",
                                );
                              },
                              alignmentOffset: const Offset(0.0, 8.0),
                            ),
                          ],
                        ),
                      )
                    ),
            ],
          ),
        );
      },
    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}