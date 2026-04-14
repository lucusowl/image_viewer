import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_viewer/dialog_tile.dart';
import 'package:image_viewer/model.dart';
import 'package:image_viewer/snackbar.dart';
import 'package:image_viewer/view.dart';
import 'package:image_viewer/window_controller.dart';

/// Actions & Intents 정의 영역
/// 각 단축키 용도의 Intent와 Action을 정의해서 작성.

/// 이전 파일로 갱신 용도
class MoveToPreviousFileIntent extends Intent {
  const MoveToPreviousFileIntent({this.fromButton});
  final bool? fromButton;
}
class MoveToPreviousFileAction extends Action<MoveToPreviousFileIntent> {
  MoveToPreviousFileAction(this.model);
  final FileModel model;
  @override
  bool isEnabled(MoveToPreviousFileIntent intent) => !model.isNotValidToPreviousFile();
  @override
  bool invoke(covariant MoveToPreviousFileIntent intent) => model.previousFile();
}

/// 다음 파일로 갱신 용도
class MoveToNextFileIntent extends Intent {
  const MoveToNextFileIntent({this.fromButton});
  final bool? fromButton;
}
class MoveToNextFileAction extends Action<MoveToNextFileIntent> {
  MoveToNextFileAction(this.model);
  final FileModel model;
  @override
  bool isEnabled(MoveToNextFileIntent intent) => !model.isNotValidToNextFile();
  @override
  bool invoke(covariant MoveToNextFileIntent intent) => model.nextFile();
}

/// 현재 파일 갱신 용도
class OpenNewFileIntent extends Intent {
  const OpenNewFileIntent({this.fromButton});
  final bool? fromButton;
}
class OpenNewFileAction extends Action<OpenNewFileIntent> {
  OpenNewFileAction(this.model);
  final FileModel model;
  @override
  bool isEnabled(OpenNewFileIntent intent) {
    // 버튼일 경우, 활성화여부 가시화
    if (intent.fromButton == true) return !model.isNotValidToPickFile();
    // 버튼이 아닌 경우, invoke에서 Enabled 처리
    return true;
  }
  @override
  Future<bool> invoke(covariant OpenNewFileIntent intent) async {
    final BuildContext? context = FocusManager.instance.primaryFocus?.context;
    // 경고를 띄울 수 없다면 비활성화
    if (context == null || context.mounted != true) return false;

    // 버튼이 아닌 Enabled 처리 => 경고 모달 열기
    if (intent.fromButton != true && model.isNotValidToPickFile()) {
      await openAlertModal(context, Icons.warning, "주의", "갱신이 준비되지 않았습니다.");
      return false;
    }
    return model.pickFile();
  }
}

/// 현재 폴더 갱신 용도
class OpenNewDirectoryIntent extends Intent {
  const OpenNewDirectoryIntent({this.fromButton});
  final bool? fromButton;
}
class OpenNewDirectoryAction extends Action<OpenNewDirectoryIntent> {
  OpenNewDirectoryAction(this.model);
  final FileModel model;
  @override
  bool isEnabled(OpenNewDirectoryIntent intent) {
    // 버튼일 경우, 활성화여부 가시화
    if (intent.fromButton == true) return !model.isNotValidToPickDirectory();
    // 버튼이 아닌 경우, invoke에서 Enabled 처리
    return true;
  }
  @override
  Future<bool> invoke(covariant OpenNewDirectoryIntent intent) async {
    final BuildContext? context = FocusManager.instance.primaryFocus?.context;
    // 경고를 띄울 수 없다면 비활성화
    if (context == null || context.mounted != true) return false;

    // 버튼이 아닌 Enabled 처리 => 경고 모달 열기
    if (intent.fromButton != true && model.isNotValidToPickDirectory()) {
      await openAlertModal(context, Icons.warning, "주의", "갱신이 준비되지 않았습니다.");
      return false;
    }
    return model.pickDirectory();
  }
}

/// 현재 파일을 파일탐색기로 열기 용도
class OpenFileByExplorerIntent extends Intent {
  const OpenFileByExplorerIntent({this.fromButton});
  final bool? fromButton;
}
class OpenFileByExplorerAction extends Action<OpenFileByExplorerIntent> {
  OpenFileByExplorerAction(this.model);
  final FileModel model;
  @override
  bool isEnabled(OpenFileByExplorerIntent intent) {
    // 버튼일 경우, 활성화여부 가시화
    if (intent.fromButton == true) return !model.isNotValidToOpenFileByExplorer();
    // 버튼이 아닌 경우, invoke에서 Enabled 처리
    return true;
  }
  @override
  Future<bool> invoke(covariant OpenFileByExplorerIntent intent) async {
    final BuildContext? context = FocusManager.instance.primaryFocus?.context;
    // 경고를 띄울 수 없다면 비활성화
    if (context == null || context.mounted != true) return false;

    // 버튼이 아닌 Enabled 처리 => 경고 모달 열기
    if (intent.fromButton != true && model.isNotValidToOpenFileByExplorer()) {
      await openAlertModal(context, Icons.warning, "주의", "파일이 준비되지 않았습니다.");
      return false;
    }
    return model.openFileByExplorer();
  }
}

/// 현재 파일을 그림판으로 열기 용도
class OpenFileByMSPaintIntent extends Intent {
  const OpenFileByMSPaintIntent({this.fromButton});
  final bool? fromButton;
}
class OpenFileByMSPaintAction extends Action<OpenFileByMSPaintIntent> {
  OpenFileByMSPaintAction(this.model);
  final FileModel model;
  @override
  bool isEnabled(OpenFileByMSPaintIntent intent) {
    // 버튼일 경우, 활성화여부 가시화
    if (intent.fromButton == true) return !model.isNotValidToOpenFileByMSPaint();
    // 버튼이 아닌 경우, invoke에서 Enabled 처리
    return true;
  }
  @override
  Future<bool> invoke(covariant OpenFileByMSPaintIntent intent) async {
    final BuildContext? context = FocusManager.instance.primaryFocus?.context;
    // 경고를 띄울 수 없다면 비활성화
    if (context == null || context.mounted != true) return false;

    // 버튼이 아닌 Enabled 처리 => 경고 모달 열기
    if (intent.fromButton != true && model.isNotValidToOpenFileByMSPaint()) {
      await openAlertModal(context, Icons.warning, "주의", "파일이 준비되지 않았습니다.");
      return false;
    }
    return model.openFileByMSPaint();
  }
}

/// 현재 이미지캐시를 다른 이름 파일로 저장 용도
class SaveAsFileIntent extends Intent {
  const SaveAsFileIntent({this.fromButton});
  final bool? fromButton;
}
class SaveAsFileAction extends Action<SaveAsFileIntent> {
  SaveAsFileAction(this.model);
  final FileModel model;
  @override
  bool isEnabled(SaveAsFileIntent intent) {
    // 버튼일 경우, 활성화여부 가시화
    if (intent.fromButton == true) return !model.isNotValidToSaveAsFile();
    // 버튼이 아닌 경우, invoke에서 Enabled 처리
    return true;
  }
  @override
  Future<bool> invoke(covariant SaveAsFileIntent intent) async {
    final BuildContext? context = FocusManager.instance.primaryFocus?.context;
    // 경고를 띄울 수 없다면 비활성화
    if (context == null || context.mounted != true) return false;

    // 버튼이 아닌 Enabled 처리 => 경고 모달 열기
    if (intent.fromButton != true && model.isNotValidToSaveAsFile()) {
      await openAlertModal(context, Icons.warning, "주의", "파일을 저장할 수 없습니다.");
      return false;
    }
    return model.saveAsFile();
  }
}

/// 현재 파일을 삭제 용도
class DeleteFileIntent extends Intent {
  const DeleteFileIntent({this.fromButton});
  final bool? fromButton;
}
class DeleteFileAction extends Action<DeleteFileIntent> {
  DeleteFileAction(this.model);
  final FileModel model;
  @override
  bool isEnabled(DeleteFileIntent intent) {
    // 버튼일 경우, 활성화여부 가시화
    if (intent.fromButton == true) return !model.isNotValidToDeleteFile();
    // 버튼이 아닌 경우, invoke에서 Enabled 처리
    return true;
  }
  @override
  Future<bool> invoke(covariant DeleteFileIntent intent) async {
    final BuildContext? context = FocusManager.instance.primaryFocus?.context;
    // 경고를 띄울 수 없다면 비활성화
    if (context == null || context.mounted != true) return false;

    // 버튼이 아닌 Enabled 처리 => 경고 모달 열기
    if (intent.fromButton != true && model.isNotValidToDeleteFile()) {
      await openAlertModal(context, Icons.warning, "주의", "파일을 삭제할 수 없습니다.");
      return false;
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
class RemoveFileInListIntent extends Intent {
  const RemoveFileInListIntent({this.fromButton});
  final bool? fromButton;
}
class RemoveFileInListAction extends Action<RemoveFileInListIntent> {
  RemoveFileInListAction(this.model);
  final FileModel model;
  @override
  bool isEnabled(RemoveFileInListIntent intent) {
    // 버튼일 경우, 활성화여부 가시화
    if (intent.fromButton == true) return !model.isNotValidToRemoveFileFromCurrentFileList();
    // 버튼이 아닌 경우, invoke에서 Enabled 처리
    return true;
  }
  @override
  Future<bool> invoke(covariant RemoveFileInListIntent intent) async {
    final BuildContext? context = FocusManager.instance.primaryFocus?.context;
    // 경고를 띄울 수 없다면 비활성화
    if (context == null || context.mounted != true) return false;

    // 버튼이 아닌 Enabled 처리 => 경고 모달 열기
    if (intent.fromButton != true && model.isNotValidToRemoveFileFromCurrentFileList()) {
      await openAlertModal(context, Icons.warning, "주의", "목록에서 제거할 수 없습니다.");
      return false;
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

/// 화면 줌 축소 용도
/// InteractiveViewer의 view zoom을 축소
class ZoomOutViewerIntent extends Intent {const ZoomOutViewerIntent();}
class ZoomOutViewerAction extends Action<ZoomOutViewerIntent> {
  ZoomOutViewerAction(this.callback);
  final VoidCallback callback;
  @override
  void invoke(covariant ZoomOutViewerIntent intent) => callback();
}

/// 화면 이동 용도
class PanViewerIntent extends Intent {
  const PanViewerIntent(this.direction);
  final MoveDirection direction;
}
class PanViewerAction extends Action<PanViewerIntent> {
  PanViewerAction(
    this.upCallback,
    this.downCallback,
    this.leftCallback,
    this.rightCallback,
  );
  final VoidCallback upCallback;
  final VoidCallback downCallback;
  final VoidCallback leftCallback;
  final VoidCallback rightCallback;
  @override
  void invoke(covariant PanViewerIntent intent) {
    switch (intent.direction) {
      case .up   : return upCallback();
      case .down : return downCallback();
      case .left : return leftCallback();
      case .right: return rightCallback();
    }
  }
}

/// 화면 세밀 이동 용도
class PanViewerSlowIntent extends Intent {
  const PanViewerSlowIntent(this.direction);
  final MoveDirection direction;
}
class PanViewerSlowAction extends Action<PanViewerSlowIntent> {
  PanViewerSlowAction(
    this.upCallback,
    this.downCallback,
    this.leftCallback,
    this.rightCallback,
  );
  final VoidCallback upCallback;
  final VoidCallback downCallback;
  final VoidCallback leftCallback;
  final VoidCallback rightCallback;
  @override
  void invoke(covariant PanViewerSlowIntent intent) {
    switch (intent.direction) {
      case .up   : return upCallback();
      case .down : return downCallback();
      case .left : return leftCallback();
      case .right: return rightCallback();
    }
  }
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
        /// 이전 파일: `Ctrl + 방향키 오른쪽`
        SingleActivator(LogicalKeyboardKey.arrowLeft, control: true): MoveToPreviousFileIntent(),
        /// 다음 파일: `Ctrl + 방향키 왼쪽`
        SingleActivator(LogicalKeyboardKey.arrowRight, control: true): MoveToNextFileIntent(),
        /// 새 파일 열기: `Ctrl + O`
        SingleActivator(LogicalKeyboardKey.keyO, control: true, includeRepeats: false): OpenNewFileIntent(),
        /// 새 폴더 열기: `Ctrl + O`
        SingleActivator(LogicalKeyboardKey.keyO, control: true, shift: true, includeRepeats: false): OpenNewDirectoryIntent(),
        /// 파일탐색기로 열기: `Shift + Alt + R`
        SingleActivator(LogicalKeyboardKey.keyR, alt: true, shift: true, includeRepeats: false): OpenFileByExplorerIntent(),
        /// 그림판으로 열기: `Ctrl + Shift + P`
        SingleActivator(LogicalKeyboardKey.keyP, control: true, shift: true, includeRepeats: false): OpenFileByMSPaintIntent(),
        /// 다른 이름으로 저장: `Ctrl + S`
        SingleActivator(LogicalKeyboardKey.keyS, control: true, includeRepeats: false): SaveAsFileIntent(),
        /// 현재 파일 삭제: `Shift + DEL`
        SingleActivator(LogicalKeyboardKey.delete, shift: true, includeRepeats: false): DeleteFileIntent(),
        /// 현재 파일을 목록에서 제거: `DEL`
        SingleActivator(LogicalKeyboardKey.delete, includeRepeats: false): RemoveFileInListIntent(),
        /// 화면 초기화: `SPACE`
        SingleActivator(LogicalKeyboardKey.space, includeRepeats: false): ResetViewerIntent(),
        /// 화면 확대: `+` 또는 확대키
        CharacterActivator('+'): ZoomInViewerIntent(),
        SingleActivator(LogicalKeyboardKey.zoomIn): ZoomInViewerIntent(),
        /// 화면 축소: `-` 또는 축소키
        CharacterActivator('-'): ZoomOutViewerIntent(),
        SingleActivator(LogicalKeyboardKey.zoomOut): ZoomOutViewerIntent(),
        /// 화면 이동: 방향키
        SingleActivator(LogicalKeyboardKey.arrowUp): PanViewerIntent(.up),
        SingleActivator(LogicalKeyboardKey.arrowDown): PanViewerIntent(.down),
        SingleActivator(LogicalKeyboardKey.arrowLeft): PanViewerIntent(.left),
        SingleActivator(LogicalKeyboardKey.arrowRight): PanViewerIntent(.right),
        /// 화면 세밀 이동: Shift + 방향키
        SingleActivator(LogicalKeyboardKey.arrowUp, shift: true): PanViewerSlowIntent(.up),
        SingleActivator(LogicalKeyboardKey.arrowDown, shift: true): PanViewerSlowIntent(.down),
        SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true): PanViewerSlowIntent(.left),
        SingleActivator(LogicalKeyboardKey.arrowRight, shift: true): PanViewerSlowIntent(.right),
        /// 화면 집중 모드: `T`
        SingleActivator(LogicalKeyboardKey.keyT, includeRepeats: false): FocusViewerIntent(),
      },
      child: child,
    );
  }
}