import 'package:flutter/material.dart';

enum DialogType {normal, confirmPopup}

class DialogTile extends StatelessWidget {
  final DialogType type;
  final IconData titleIcon;
  final String titleText;
  final String bodyText;
  final List<Widget> bottomActionWidgets;

  const DialogTile({
    super.key,
    this.type = .normal,
    this.titleIcon = Icons.info,
    this.titleText = "알림",
    this.bodyText = "팝업이 열렸습니다.",
    this.bottomActionWidgets = const []});

  @override
  Widget build(BuildContext context) {
    return Material(
      // 배경색
      color: Theme.of(context).colorScheme.surface,
      // 레이어 테두리
      shape: RoundedRectangleBorder(
        borderRadius: .circular(16.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),),
      clipBehavior: .hardEdge,
      child: Column(
        mainAxisSize: .min,
        children: [
          /// #1 상단 영역
          Container(
            padding: const .all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,),
            child: Row(
              spacing: 16.0,
              children: [
                Icon(titleIcon, size: 24.0, color: Colors.amber,),
                Expanded(child: Tooltip(
                  message: titleText,
                  waitDuration: const Duration(milliseconds: 700),
                  child: Text(
                    titleText,
                    style: const TextStyle(fontSize: 18.0),
                    overflow: .ellipsis,
                    maxLines: 1,),),),],),),

          /// #2-1 상세 내용 영역
          Flexible(child: SingleChildScrollView(
            padding: const .symmetric(horizontal: 16.0, vertical: 24.0),
            child: Container(
              width: double.infinity,
              alignment: .topLeft,
              child: Text(bodyText),),),),

          /// #2-2 하단 영역
          switch (type) {
            /// [.confirmPopup]: 확인|취소 버튼
            /// 확인 클릭시 true를 반환
            .confirmPopup => Padding(
                padding: const .fromLTRB(16.0, 0.0, 16.0, 16.0),
                child: Row(
                  spacing: 8.0,
                  children: bottomActionWidgets,),),

            /// [.normal]
            /// 이외 위젯목록이 있는 경우: 일반 스크롤 영역
            /// 전달받은 행동처리 위젯을 스크롤로 빌드
            _ when bottomActionWidgets.isNotEmpty =>
              Container(
              alignment: .centerLeft,
              child: SingleChildScrollView(
                padding: const .fromLTRB(16.0, 0.0, 16.0, 16.0),
                scrollDirection: .horizontal,
                child: Row(
                  spacing: 8.0,
                  children: bottomActionWidgets),),),

            /// [.normal]
            /// 이외 위젯 목록이 없는 경우: 빈 영역
            _ => const SizedBox.shrink(),
          }
        ],),);
  }
}

/// 선택(확인 또는 취소) 팝업 모달을 열고 확인여부를 반환
/// - [icon]: 모달 상단과 확인 버튼 아이콘
/// - [title]: 모달 상단 제목 문구
/// - [body]: 모달 중앙 상세 설면 문구
/// - [confirmButtonLabel]: (선택) 확인 버튼 표시문자, 기본값: "확인"
Future<bool> openConfirmModal(
  BuildContext buildContext,
  IconData icon,
  String title,
  String body,
  [String confirmButtonLabel = "확인"]
) async {
  final isDeleted = await showDialog(
    context: buildContext,
    builder:(BuildContext context) => Dialog(
      constraints: const BoxConstraints(maxWidth: 360.0),
      child: DialogTile(
        type: DialogType.confirmPopup,
        titleText: title,
        titleIcon: icon,
        bodyText: body,
        bottomActionWidgets: [
          Expanded(child: TextButton.icon(
            onPressed: () {Navigator.of(context).pop(true);},
            icon: Icon(icon),
            label: Text(confirmButtonLabel),
            autofocus: true,),),
          Expanded(child: TextButton.icon(
            onPressed: () {Navigator.of(context).pop();},
            icon: const Icon(Icons.cancel),
            label: const Text("취소"),),),],),),);
  return (true == isDeleted);
}