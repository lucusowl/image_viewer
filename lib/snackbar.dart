import 'package:flutter/material.dart';

class GlobalSnackbar {
  static final snackBarKey = GlobalKey<ScaffoldMessengerState>();

  /// SnackBar, 일반 메세지 표시
  /// - [message]: 스낵바에 표시할 내용
  /// - [wait]: 현재 표시된 스낵바 닫힐 때까지 대기여부, 기본값: false(바로갱신)
  static void show(String message, {bool wait = false}) {
    // snackbar를 표시할 수 있는지
    if (snackBarKey.currentState == null) return;
    final BuildContext? context = snackBarKey.currentContext;
    if (context == null || context.mounted != true) return;

    if (!wait) snackBarKey.currentState?.removeCurrentSnackBar();
    snackBarKey.currentState?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: .circular(16.0),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),),
        content: Text(message),),
    );
  }

  /// SnackBar, 오류 메세지 표시
  /// - [message]: 스낵바에 표시할 내용
  /// - [wait]: 현재 표시된 스낵바 닫힐 때까지 대기여부, 기본값: false(바로갱신)
  static void showError(String message, {bool wait = false}) {
    // snackbar를 표시할 수 있는지
    if (snackBarKey.currentState == null) return;
    final BuildContext? context = snackBarKey.currentContext;
    if (context == null || context.mounted != true) return;

    if (!wait) snackBarKey.currentState?.removeCurrentSnackBar();
    snackBarKey.currentState?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        closeIconColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: .circular(16.0),
          side: BorderSide(color: Colors.red.shade400),),
        content: Text(message),
      )
    );
  }
}