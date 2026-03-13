import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_viewer/model.dart';

/// Actions & Intents 정의 영역
/// 각 단축키 용도의 Intent와 Action을 정의해서 작성.

/// 이전 파일로 갱신 용도
class MoveToPreviousFileIntent extends Intent {const MoveToPreviousFileIntent();}
class MoveToPreviousFileAction extends Action<MoveToPreviousFileIntent> {
  MoveToPreviousFileAction(this.model);
  final FileModel model;
  @override
  void invoke(covariant MoveToPreviousFileIntent intent) => model.previousFile();
}

/// 다음 파일로 갱신 용도
class MoveToNextFileIntent extends Intent {const MoveToNextFileIntent();}
class MoveToNextFileAction extends Action<MoveToNextFileIntent> {
  MoveToNextFileAction(this.model);
  final FileModel model;
  @override
  void invoke(covariant MoveToNextFileIntent intent) => model.nextFile();
}

/// 현재 파일 갱신 용도
class OpenNewFileIntent extends Intent {const OpenNewFileIntent();}
class OpenNewFileAction extends Action<OpenNewFileIntent> {
  OpenNewFileAction(this.model);
  final FileModel model;
  @override
  void invoke(covariant OpenNewFileIntent intent) => model.pickFile();
}

/// 화면 맞추기 용도
/// InteractiveViewer의 view를 초기화
class ResetViewerIntent extends Intent {const ResetViewerIntent();}
class ResetViewerAction extends Action<ResetViewerIntent> {
  ResetViewerAction(this.callback);
  final VoidCallback callback;
  @override
  void invoke(covariant ResetViewerIntent intent) => callback();
}

/// 화면 줌 확대 용도
/// InteractiveViewer의 view zoom을 확대
class ZoomInViewerIntent extends Intent {const ZoomInViewerIntent();}
class ZoomInViewerAction extends Action<ZoomInViewerIntent> {
  ZoomInViewerAction(this.callback);
  final VoidCallback callback;
  @override
  void invoke(covariant ZoomInViewerIntent intent) => callback();
}

/// 화면 줌 취소 용도
/// InteractiveViewer의 view zoom을 취소
class ZoomOutViewerIntent extends Intent {const ZoomOutViewerIntent();}
class ZoomOutViewerAction extends Action<ZoomOutViewerIntent> {
  ZoomOutViewerAction(this.callback);
  final VoidCallback callback;
  @override
  void invoke(covariant ZoomOutViewerIntent intent) => callback();
}

/// 화면 집중 용도
/// InteractiveViewer가 있는 영역만을 표시
class FocusViewerIntent extends Intent {const FocusViewerIntent();}
class FocusViewerAction extends Action<FocusViewerIntent> {
  FocusViewerAction(this.callback);
  final VoidCallback callback;
  @override
  void invoke(covariant FocusViewerIntent intent) => callback();
}

/// 전역에서 사용할 단축키를 등록하는 위젯
class GlobalShortcutWrapper extends StatelessWidget {
  final Widget child;
  const GlobalShortcutWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        ///
      },
      child: child,
    );
  }
}

/// ViewPage에서 사용할 단축키를 등록하는 위젯
class ViewPageShortcutWrapper extends StatelessWidget {
  final Widget child;
  const ViewPageShortcutWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        /// 이전 파일: `방향키 오른쪽`
        SingleActivator(LogicalKeyboardKey.arrowLeft): MoveToPreviousFileIntent(),
        /// 다음 파일: `방향키 왼쪽`
        SingleActivator(LogicalKeyboardKey.arrowRight): MoveToNextFileIntent(),
        /// 새 파일 열기: `Ctrl + o`
        SingleActivator(LogicalKeyboardKey.keyO, control: true): OpenNewFileIntent(),
        /// 화면 초기화: `space`
        SingleActivator(LogicalKeyboardKey.space): ResetViewerIntent(),
        /// 화면 확대: `+` 또는 확대키
        CharacterActivator('+'): ZoomInViewerIntent(),
        SingleActivator(LogicalKeyboardKey.zoomIn): ZoomInViewerIntent(),
        /// 화면 확대: `-` 또는 축소키
        CharacterActivator('-'): ZoomOutViewerIntent(),
        SingleActivator(LogicalKeyboardKey.zoomOut): ZoomOutViewerIntent(),
        /// 화면 집중 모드: `t`
        SingleActivator(LogicalKeyboardKey.keyT): FocusViewerIntent(),
      },
      child: child,
    );
  }
}