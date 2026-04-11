import 'package:flutter/services.dart';
import 'package:image_viewer/snackbar.dart';

/// Windows 네이티브 코드 연결 객체
/// 상세한 코드는 `/windows/runner/flutter_window.cpp`를 확인
class WindowController {
  static final platform = MethodChannel('com.example.app/window_control');

  /// Window 창의 FullScreen을 토글
  static void toggleFullscreen() {
    platform.invokeMethod('toggleFullScreen').catchError((e, s) {
      GlobalSnackbar.showError("전체화면 토글 실패");
    });
  }

  /// Windows 창의 Fullscreen을 강제 해제
  static void unsetFullscreen() {
    platform.invokeMethod('unsetFullScreen').catchError((e, s) {
      GlobalSnackbar.showError("전체화면 토글 실패");
    });
  }
}