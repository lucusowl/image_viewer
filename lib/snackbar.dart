import 'package:flutter/material.dart';

class GlobalSnackbar {
  static final snackBarKey = GlobalKey<ScaffoldMessengerState>();

  /// SnackBar, 일반 메세지 표시
  /// - [message]: 스낵바에 표시할 내용
  /// - [wait]: 현재 표시된 스낵바 닫힐 때까지 대기여부
  static void show(String message, {bool wait = false}) {
    // snackbar를 표시할 수 있는지
    if (snackBarKey.currentState == null) return;
    final BuildContext? context = snackBarKey.currentContext;
    if (context == null || context.mounted != true) return;

    if (!wait) snackBarKey.currentState?.removeCurrentSnackBar();
    snackBarKey.currentState?.showSnackBar(
      SnackBar(
        behavior: .floating,
        duration: const Duration(seconds: 25),
        showCloseIcon: true,
        closeIconColor: Colors.white,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withAlpha(138), // 54%
        shape: RoundedRectangleBorder(
          borderRadius: .circular(16.0),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),),
        width: 200.0,
        // margin: .only(bottom: 72.0),
        padding: .fromLTRB(14, 0, 0, 0),
        content: Text(
          message,
          style: TextStyle(color: Colors.white),),),
    );
  }

  /// SnackBar, 오류 메세지 표시
  /// - [message]: 스낵바에 표시할 내용
  /// - [wait]: 현재 표시된 스낵바 닫힐 때까지 대기여부
  static void showError(String message, {bool wait = false}) {
    // snackbar를 표시할 수 있는지
    if (snackBarKey.currentState == null) return;
    final BuildContext? context = snackBarKey.currentContext;
    if (context == null || context.mounted != true) return;

    if (!wait) snackBarKey.currentState?.removeCurrentSnackBar();
    snackBarKey.currentState?.showSnackBar(
      SnackBar(
        behavior: .floating,
        duration: const Duration(seconds: 25),
        showCloseIcon: true,
        closeIconColor: Colors.red,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withAlpha(138), // 54%
        shape: RoundedRectangleBorder(
          borderRadius: .circular(16.0),
          side: BorderSide(color: Colors.red.shade400),),
        width: 200.0,
        // margin: .only(bottom: 72.0),
        padding: .fromLTRB(14, 0, 0, 0),
        content: Text(
          message,
          style: TextStyle(color: Colors.white),),),
    );
  }
}