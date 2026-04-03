import 'package:flutter/material.dart';
import 'package:image_viewer/dialog_tile.dart';
import 'package:image_viewer/shortcut.dart';

/// 에러 코드
/// - `noPath` : 경로 없음
/// - `noFile` : 파일 없음
/// - `notImage` : 파일이 이미지형식이 아님
/// - `errorLoadImage` : 이미지를 띄우는 도중 문제 발생
/// - `errorLoadFiles` : 파일목록을 가져오는 도중 문제 발생
/// - `unknown` : 알 수 없는 오류
enum ErrorCode {
  noPath,
  noFile,
  notImage,
  errorLoadImage,
  errorLoadFiles,
  unknown,
}

/// 에러 대처 옵션 코드
/// - `none` : 대처 없음
/// - `newFile` : 새 파일 열기
/// - `appRefresh` : 앱 재시작
enum ErrorHandleOption {
  none,
  newFile,
  appRefresh,
}
/// 에러 대처용 타일위젯
class ErrorTile extends StatelessWidget {
  final ErrorCode errorCode;
  final String? errorMessage;

  const ErrorTile({super.key,
    required this.errorCode,
             this.errorMessage
  });

  @override
  Widget build(BuildContext context) {
    String headText;
    String descriptionText = '';
    ErrorHandleOption errorHandleOption = .none;

    switch (errorCode) {
      case ErrorCode.noPath:
        /// 요청 파일 경로가 없음
        headText = "파일 경로를 받지 못함";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n새 파일을 선택해주세요."
        : "파일의 경로를 받지 못했습니다.\n새 파일을 선택해주세요.";
        errorHandleOption = .newFile;
        break;
      case ErrorCode.noFile:
        /// 요청한 파일이 없음
        headText = "파일이 보이지 않음";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n새 파일을 선택해주세요."
        : "지정한 파일이 존재하지 않습니다.\n새 파일을 선택해주세요.";
        errorHandleOption = .newFile;
        break;
      case ErrorCode.notImage:
        /// 요청한 파일이 이미지가 아님
        headText = "파일이 이미지 형식이 아님";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n새 파일을 선택해주세요."
        : "지정한 파일이 이미지 형식의 파일이 아닙니다.\n이미지 형식인 새 파일을 선택해주세요.";
        errorHandleOption = .newFile;
        break;
      case ErrorCode.errorLoadImage:
        /// 요청한 이미지를 띄우는 도중 문제 발생
        headText = "이미지를 띄우는 도중 문제 발생";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n새 파일을 선택해주세요."
        : "이미지를 띄우는 도중에 알 수 없는 원인으로 문제가 발생했습니다.\n새 파일을 선택해주세요.";
        errorHandleOption = .newFile;
        break;
      case ErrorCode.errorLoadFiles:
        /// 파일 목록을 불러오는 도중 문제 발생
        headText = "파일 목록을 불러오는 도중 문제 발생";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n새 파일을 선택해주세요."
        : "갱신요청된 파일과 관련된 목록을 불러오는 도중 문제가 발생했습니다.\n새 파일을 선택해주세요.";
        errorHandleOption = .newFile;
        break;
      
      default:
        /// 알 수 없는 에러 = 표시할 에러가 없음
        headText = "앱 재시작 필요";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n앱을 재시작 해주세요."
        : "예상치 못한 에러가 발생했습니다.\n앱을 재시작 해주세요.";
        errorHandleOption = .appRefresh;
    }

    List<Widget> errorHandleWidget = switch (errorHandleOption) {
      // 새 파일 선택 처리
      .newFile => [
        TextButton.icon(
          onPressed: Actions.handler<OpenNewFileIntent>(context, OpenNewFileIntent()),
          icon: const Icon(Icons.file_open),
          label: const Text("파일 선택")
        ),
        TextButton.icon(
          onPressed: Actions.handler<OpenNewDirectoryIntent>(context, OpenNewDirectoryIntent()),
          icon: const Icon(Icons.folder_open),
          label: const Text("폴더 선택")
        ),
      ],

      // TODO: 앱 재시작 처리
      .appRefresh => [],

      // 그 이외 에러처리 = Action없음
      _ => [],
    };

    return Center(
      child: Container(
        // 내용이 많아질 경우 대비
        // - 너비 제한
        // - 상하 마진 제한 -> 내부 스크롤 동작
        constraints: const BoxConstraints(maxWidth: 480.0),
        margin: const .symmetric(vertical: 64.0),
        child: DialogTile(
          type: .normal,
          titleText: headText,
          bodyText: descriptionText,
          bottomActionWidgets: errorHandleWidget,),),);
  }
}
