import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_viewer/model.dart';
import 'package:image_viewer/shortcut.dart';

class FileMoveIndicator extends StatelessWidget {
  const FileMoveIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FileModelProvider.of(context).model,
      builder: (context, child) {
        final fileModel = FileModelProvider.of(context).model;
        return Stack(
          children: [
            // 이전 파일 이동 버튼
            if (!fileModel.isFirst)
              Align(
                alignment: .centerLeft,
                child: Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: IconButton(
                    onPressed: Actions.handler<MoveToPreviousFileIntent>(context, MoveToPreviousFileIntent()),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: "이전",
                  ),
                )
              ),
            // 다음 파일 이동 버튼
            if (!fileModel.isLast)
              Align(
                alignment: .centerRight,
                child: Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: IconButton(
                    onPressed: Actions.handler<MoveToNextFileIntent>(context, MoveToNextFileIntent()),
                    icon: const Icon(Icons.arrow_forward),
                    tooltip: "다음",
                  ),
                )
              ),
          ],
        );
      }
    );
  }
}

class ViewerBottomPanel extends StatelessWidget {
  const ViewerBottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .bottomCenter,
      child: Container(
        padding: const .all(12.0),
        decoration: const BoxDecoration(color: Colors.black54),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            Flexible(
              child: Padding(
                padding: const .all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: .horizontal,
                  child: ListenableBuilder(
                    listenable: FileModelProvider.of(context).model,
                    builder: (BuildContext context, _) {
                      return Text(FileModelProvider.of(context).model.fileName ?? "파일 없음", maxLines: 1,);
                    }
                  ),
                ),
              ),
            ),

            IconButton(
              onPressed: Actions.handler<ResetViewerIntent>(context, const ResetViewerIntent()),
              icon: const Icon(Icons.fit_screen),
              tooltip: "화면 초기화 (space)",
            ),
            IconButton(
              onPressed: Actions.handler<ZoomInViewerIntent>(context, const ZoomInViewerIntent()),
              icon: const Icon(Icons.zoom_in),
              tooltip: "2배 확대 (+)"
            ),
            IconButton(
              onPressed: Actions.handler<ZoomOutViewerIntent>(context, const ZoomOutViewerIntent()),
              icon: const Icon(Icons.zoom_out),
              tooltip: "2배 축소 (-)"
            ),

            MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  onPressed: Actions.handler<OpenNewFileIntent>(context, OpenNewFileIntent()),
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyO, control: true),
                  leadingIcon: const Icon(Icons.file_open, size: 18.0),
                  child: const Text("새 파일 열기"),
                ),
                MenuItemButton(
                  onPressed: Actions.handler<OpenNewDirectoryIntent>(context, OpenNewDirectoryIntent()),
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyO, control: true, shift: true),
                  leadingIcon: const Icon(Icons.folder_open, size: 18.0),
                  child: const Text("새 폴더 열기"),
                ),
                // MenuItemButton(
                //   // onPressed: Actions.handler<T>(context, T()),
                //   shortcut: const SingleActivator(LogicalKeyboardKey.keyP, control: true, shift: true),
                //   leadingIcon: const Icon(Icons.palette, size: 18.0),
                //   child: const Text("그림판으로 열기"),
                // ),
                // MenuItemButton(
                //   // onPressed: Actions.handler<T>(context, T()),
                //   shortcut: const SingleActivator(LogicalKeyboardKey.keyS, control: true),
                //   leadingIcon: const Icon(Icons.save, size: 18.0),
                //   child: const Text("다른 이름으로 저장"),
                // ),
                MenuItemButton(
                  onPressed: Actions.handler<DeleteFileIntent>(context, DeleteFileIntent()),
                  shortcut: const SingleActivator(LogicalKeyboardKey.delete, shift: true),
                  leadingIcon: const Icon(Icons.delete_forever, size: 18.0),
                  child: const Text("삭제"),
                ),
                MenuItemButton(
                  onPressed: Actions.handler<RemoveFileInListIntent>(context, RemoveFileInListIntent()),
                  shortcut: const SingleActivator(LogicalKeyboardKey.delete),
                  leadingIcon: const Icon(Icons.remove_circle, size: 18.0),
                  child: const Text("목록에서 제거"),
                ),
                const Divider(),
                MenuItemButton(
                  onPressed: Actions.handler<FocusViewerIntent>(context, FocusViewerIntent()),
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyT),
                  leadingIcon: const Icon(Icons.image, size: 18.0),
                  child: const Text("집중 모드"),
                ),
                MenuItemButton(
                  onPressed: Actions.handler<FullScreenIntent>(context, FullScreenIntent()),
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyF),
                  leadingIcon: const Icon(Icons.fullscreen, size: 18.0),
                  child: const Text("전체화면 모드"),
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
    );
  }
}

class ViewerActionOverlay extends StatelessWidget {
  const ViewerActionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: FileModelProvider.of(context).model.isReadyFileList,
      builder:(_, bool isReady, Widget? viewerBottomPanel) {
        return Stack(
          children: [
            // 좌우 파일 이동 버튼
            // 파일목록이 갱신중이라면 미표시
            Visibility(
              visible: isReady,
              child: const FileMoveIndicator(),
            ),
            // 하단 화면 조작 패널
            viewerBottomPanel!,
          ],
        );
      },
      child: const ViewerBottomPanel(),
    );
  }
}