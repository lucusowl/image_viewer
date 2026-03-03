import 'package:flutter/material.dart';
import 'package:image_viewer/model.dart';

/// 에러 코드
/// - `noPath` : 경로 없음
/// - `noFile` : 파일 없음
/// - `notImage` : 파일이 이미지형식이 아님
/// - `errorLoadImage` : 이미지를 띄우는 도중 문제 발생
/// - `unknown` : 알 수 없는 오류
enum ErrorCode {
  noPath,
  noFile,
  notImage,
  errorLoadImage,
  unknown,
}

/// 에러 대처 옵션 코드
/// - `none` : 대처 없음
/// - `newFile` : 새 파일 열기
/// - `appRefresh` : 앱 재시작, TODO: 앱 재시작
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
    ErrorHandleOption errorHandleOption = ErrorHandleOption.none;

    switch (errorCode) {
      case ErrorCode.noPath:
        /// 요청 파일 경로가 없음
        headText = "파일 경로를 받지 못함";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n새 파일을 선택해주세요."
        : "파일의 경로를 받지 못했습니다.\n새 파일을 선택해주세요.";
        errorHandleOption = ErrorHandleOption.newFile;
        break;
      case ErrorCode.noFile:
        /// 요청한 파일이 없음
        headText = "파일이 보이지 않음";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n새 파일을 선택해주세요."
        : "지정한 파일이 존재하지 않습니다.\n새 파일을 선택해주세요.";
        errorHandleOption = ErrorHandleOption.newFile;
        break;
      case ErrorCode.notImage:
        /// 요청한 파일이 이미지가 아님
        headText = "파일이 이미지 형식이 아님";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n새 파일을 선택해주세요."
        : "지정한 파일이 이미지 형식의 파일이 아닙니다.\n이미지 형식인 새 파일을 선택해주세요.";
        errorHandleOption = ErrorHandleOption.newFile;
        break;
      case ErrorCode.errorLoadImage:
        /// 요청한 이미지를 띄우는 도중 문제 발생
        headText = "이미지를 띄우는 도중 문제 발생";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n새 파일을 선택해주세요."
        : "이미지를 띄우는 도중에 알 수 없는 원인으로 문제가 발생했습니다.\n새 파일을 선택해주세요.";
        errorHandleOption = ErrorHandleOption.newFile;
        break;
      default:
        /// 알 수 없는 에러 = 표시할 에러가 없음
        headText = "앱 재시작 필요";
        descriptionText = (errorMessage != null)
        ? "$errorMessage\n앱을 재시작 해주세요."
        : "예상치 못한 에러가 발생했습니다.\n앱을 재시작 해주세요.";
        errorHandleOption = ErrorHandleOption.appRefresh;
    }

    Widget? errorHandleWidget;
    switch (errorHandleOption) {
      case ErrorHandleOption.newFile:
        errorHandleWidget = Row(
          spacing: 8.0,
          children: [
            TextButton.icon(
              onPressed: FileModelProvider.of(context).pickFile,
              icon: Icon(Icons.file_open),
              label: Text("파일 선택")
            ),
          ],
        );
        break;
      default:
        errorHandleWidget = null;
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 480.0),
        decoration: BoxDecoration(
          border: .all(color: Colors.amber),
          // borderRadius: .circular(16.0)
        ),
        margin: .symmetric(vertical: 64.0),
        child: Column(
          mainAxisSize: .min,
          children: [
            /// #1 제목 영역
            Container(
              padding: .all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                // borderRadius: .vertical(top: .circular(16.0)),
              ),
              child: Row(
                spacing: 16.0,
                children: [
                  Icon(Icons.warning, size: 24.0, color: Colors.amber,),
                  Expanded(child: Tooltip(
                    message: headText,
                    waitDuration: const Duration(milliseconds: 700),
                    child: Text(
                      headText,
                      style: TextStyle(fontSize: 18.0),
                      overflow: .ellipsis,
                      maxLines: 1,
                    ),
                  )),
                ],
              ),
            ),

            /// #2-1 상세 내용 영역
            Flexible(
              child: SingleChildScrollView(
                padding: .all(16.0),
                child: Container(
                  width: double.infinity,
                  alignment: .topLeft,
                  child: Text(descriptionText),
                )
              ),
            ),

            /// #2-2 행동 영역
            if (errorHandleWidget != null) Container(
                decoration: BoxDecoration(
                  // borderRadius: .vertical(bottom: .circular(16.0)),
                ),
                alignment: .topLeft,
                child: SingleChildScrollView(
                  padding: .fromLTRB(16.0, 0.0, 16.0, 16.0),
                  scrollDirection: .horizontal,
                  child: errorHandleWidget
                )
              ),
          ],
        ),
      ),
    );
  }
}
