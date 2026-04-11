import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_viewer/dialog_tile.dart';
import 'package:image_viewer/model.dart';
import 'package:image_viewer/snackbar.dart';

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
  Future<bool> invoke(covariant OpenNewFileIntent intent) => model.pickFile();
}

/// 현재 폴더 갱신 용도
class OpenNewDirectoryIntent extends Intent {const OpenNewDirectoryIntent();}
class OpenNewDirectoryAction extends Action<OpenNewDirectoryIntent> {
  OpenNewDirectoryAction(this.model);
  final FileModel model;
  @override
  Future<bool> invoke(covariant OpenNewDirectoryIntent intent) => model.pickDirectory();
}

/// 현재 파일을 파일탐색기로 열기 용도
class OpenFileByExplorerIntent extends Intent {const OpenFileByExplorerIntent();}
class OpenFileByExplorerAction extends Action<OpenFileByExplorerIntent> {
  OpenFileByExplorerAction(this.model);
  final FileModel model;
  @override
  bool invoke(covariant OpenFileByExplorerIntent intent) => model.openFileByExplorer();
}

/// 현재 파일을 그림판으로 열기 용도
class OpenFileByMSPaintIntent extends Intent {const OpenFileByMSPaintIntent();}
class OpenFileByMSPaintAction extends Action<OpenFileByMSPaintIntent> {
  OpenFileByMSPaintAction(this.model);
  final FileModel model;
  @override
  bool invoke(covariant OpenFileByMSPaintIntent intent) => model.openFileByMSPaint();
}

/// 현재 이미지캐시를 다른 이름 파일로 저장 용도
class SaveAsFileIntent extends Intent {const SaveAsFileIntent();}
class SaveAsFileAction extends Action<SaveAsFileIntent> {
  SaveAsFileAction(this.model);
  final FileModel model;
  @override
  Future<bool> invoke(covariant SaveAsFileIntent intent) => model.saveAsFile();
}

/// 현재 파일을 삭제 용도
class DeleteFileIntent extends Intent {const DeleteFileIntent();}
class DeleteFileAction extends Action<DeleteFileIntent> {
  DeleteFileAction(this.model);
  final FileModel model;
  @override
  Future<bool> invoke(covariant DeleteFileIntent intent) async {
    final BuildContext? context = FocusManager.instance.primaryFocus?.context;
    // 경고를 띄울 수 없다면 비활성화
    if (context == null || context.mounted != true) return false;

    // 파일 없음 => 경고 모달 열기
    if (model.isNotValidToDeleteFile()) {
      await openAlertModal(context, Icons.warning, "파일 없음", "삭제할 파일이 없습니다.");
      return true;
    }

    // 삭제 전 확인
    final bool isDeleted = await openConfirmModal(context,
      Icons.delete_forever,
      "주의: 파일 삭제",
      "현재 파일을 완전히 삭제합니다.\n파일을 삭제하기 전 확인합니다.",
      "삭제");
    if (!isDeleted) return false;

    // 삭제 수행 및 결과 반환
    // 삭제 처리가 시작 알림, (용량이 큰 파일일 경우 오래 걸림)
    GlobalSnackbar.show("파일 삭제 중");
    final result = await model.deleteFile();
    /// 삭제 처리가 완료 알림
    if (result) GlobalSnackbar.show("파일 삭제 완료");
    return result;
  }
}

/// 현재 파일을 목록에서 제거 용도
class RemoveFileInListIntent extends Intent {const RemoveFileInListIntent();}
class RemoveFileInListAction extends Action<RemoveFileInListIntent> {
  RemoveFileInListAction(this.model);
  final FileModel model;
  @override
  Future<bool> invoke(covariant RemoveFileInListIntent intent) async {
    final BuildContext? context = FocusManager.instance.primaryFocus?.context;
    // 경고를 띄울 수 없다면 비활성화
    if (context == null || context.mounted != true) return false;

    // 파일 없음 => 경고 모달 열기
    if (model.isNotValidToRemoveFileFromCurrentFileList()) {
      await openAlertModal(context, Icons.warning, "파일 없음", "제거할 파일이 없습니다.");
      return true;
    }

    // 제거 전 확인
    final bool isDeleted = await openConfirmModal(context,
      Icons.remove_circle,
      "주의: 목록에서 파일 제거",
      "현재 목록에서 이 파일을 완전히 제거합니다.\n파일을 제거하기 전 확인합니다.",
      "제거");
    if (!isDeleted) return false;

    // 제거 수행 및 결과 반환
    final result = model.removeFileFromCurrentFileList();
    // 제거 수행 완료 알림
    if (result) GlobalSnackbar.show("목록에서 제거됨");
    return result;
  }
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

/// 전체화면 모드 토글 용도
class ToggleFullScreenIntent extends Intent {const ToggleFullScreenIntent();}
class ToggleFullScreenAction extends Action<ToggleFullScreenIntent> {
  ToggleFullScreenAction();
  @override
  void invoke(covariant ToggleFullScreenIntent intent) => WindowController.toggleFullscreen();
}

/// 전체화면 모드 해제 용도
class UnsetFullScreenIntent extends Intent {const UnsetFullScreenIntent();}
class UnsetFullScreenAction extends Action<UnsetFullScreenIntent> {
  UnsetFullScreenAction();
  @override
  void invoke(covariant UnsetFullScreenIntent intent) => WindowController.unsetFullscreen();
}

/// 전역에서 사용할 단축키를 등록하는 위젯
class GlobalShortcutWrapper extends StatelessWidget {
  final Widget child;
  const GlobalShortcutWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        /// 전체화면 모드 토글: `F11` 또는 `F`
        SingleActivator(LogicalKeyboardKey.f11): ToggleFullScreenIntent(),
        SingleActivator(LogicalKeyboardKey.keyF): ToggleFullScreenIntent(),
        /// 전체화면 모드 해제: `ESC`
        SingleActivator(LogicalKeyboardKey.escape): UnsetFullScreenIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ToggleFullScreenIntent: ToggleFullScreenAction(),
          UnsetFullScreenIntent: UnsetFullScreenAction(),
        },
        child: child
      ),
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
        /// 새 파일 열기: `Ctrl + O`
        SingleActivator(LogicalKeyboardKey.keyO, control: true): OpenNewFileIntent(),
        /// 새 폴더 열기: `Ctrl + O`
        SingleActivator(LogicalKeyboardKey.keyO, control: true, shift: true): OpenNewDirectoryIntent(),
        /// 파일탐색기로 열기: `Shift + Alt + R`
        SingleActivator(LogicalKeyboardKey.keyR, alt: true, shift: true): OpenFileByExplorerIntent(),
        /// 그림판으로 열기: `Ctrl + Shift + P`
        SingleActivator(LogicalKeyboardKey.keyP, control: true, shift: true): OpenFileByMSPaintIntent(),
        /// 다른 이름으로 저장: `Ctrl + S`
        SingleActivator(LogicalKeyboardKey.keyS, control: true): SaveAsFileIntent(),
        /// 현재 파일 삭제: `Shift + DEL`
        SingleActivator(LogicalKeyboardKey.delete, shift: true): DeleteFileIntent(),
        /// 현재 파일을 목록에서 제거: `DEL`
        SingleActivator(LogicalKeyboardKey.delete): RemoveFileInListIntent(),
        /// 화면 초기화: `SPACE`
        SingleActivator(LogicalKeyboardKey.space): ResetViewerIntent(),
        /// 화면 확대: `+` 또는 확대키
        CharacterActivator('+'): ZoomInViewerIntent(),
        SingleActivator(LogicalKeyboardKey.zoomIn): ZoomInViewerIntent(),
        /// 화면 확대: `-` 또는 축소키
        CharacterActivator('-'): ZoomOutViewerIntent(),
        SingleActivator(LogicalKeyboardKey.zoomOut): ZoomOutViewerIntent(),
        /// 화면 집중 모드: `T`
        SingleActivator(LogicalKeyboardKey.keyT): FocusViewerIntent(),
      },
      child: child,
    );
  }
}