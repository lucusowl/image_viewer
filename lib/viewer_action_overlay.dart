import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_viewer/model.dart';
import 'package:image_viewer/shortcut.dart';

class ViewerActionOverlay extends StatelessWidget {
  const ViewerActionOverlay({super.key});
 
  @override
  Widget build(BuildContext context) {
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

        // 하단 화면 조작 패널
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

                IconButton(
                  onPressed: Actions.handler<ResetViewerIntent>(context, ResetViewerIntent()),
                  icon: const Icon(Icons.fit_screen),
                  tooltip: "화면 초기화 (space)",
                ),
                IconButton(
                  onPressed: Actions.handler<ZoomInViewerIntent>(context, ZoomInViewerIntent()),
                  icon: const Icon(Icons.zoom_in),
                  tooltip: "2배 확대 (+)"
                ),
                IconButton(
                  onPressed: Actions.handler<ZoomOutViewerIntent>(context, ZoomOutViewerIntent()),
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
    );
  }
}