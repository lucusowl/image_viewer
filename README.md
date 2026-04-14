# 이미지 뷰어
![GitHub Release](https://img.shields.io/github/v/release/lucusowl/image_viewer)
![GitHub License](https://img.shields.io/github/license/lucusowl/image_viewer)

Windows 기본 사진 앱은 "앱 성능 및 앱의 기능 사용에 대한 정보를 선택적으로 수집합니다."
데이터 수집 옵트인에 동의하지 않고 **단순히 사진뷰어로써의 기능만을 사용**하고자 제작.

Windows 용으로 제작되었으며 앱은 flutter를 기반으로 제작.

## 기능

구현된 기능은 되도록 마우스입력과 키보드입력 모두 동작할 수 있게 구현.

구현된 기능과 각 마우스, 단축키 목록

기능|마우스|단축키|비고
-|-|-|-
화면초기화|버튼|`SPACE`|
zoom toggle|화면더블클릭|-|
zoom in|버튼 & 스크롤|`+`|trackpad가능
zoom out|버튼 & 스크롤|`-`|trackpad가능
pan|드래그|`Arrow-Key`(기본),<br>`Shift + Arrow-Key`(미세)|trackpad가능
집중 모드|화면클릭|`T`|
전체화면 모드|버튼|`F`, `F11`|
이전 파일|버튼|`Ctrl + Arrow-Left`|
이후 파일|버튼|`Ctrl + Arrow-Right`|
새파일 열기|버튼|`Ctrl + O`|
새폴더 열기|버튼|`Ctrl + Shift + O`|
파일탐색기 열기|버튼|`Shift + Alt + R`|
그림판으로 열기|버튼|`Ctrl + Shift + P`|
다른이름으로 저장|버튼|`Ctrl + S`|캐시값 저장
삭제|버튼|`Shift + DEL`|파일 영구삭제
목록에서 제거|버튼|`DEL`|

zoom 배율은 50% ~ 1000% 범위를 가짐.

## 라이선스 License

본 프로젝트는 [MIT License](LICENSE) 하에 배포.  
third-party 라이선스는 [NOTICE](NOTICE) 파일에 요약 및 고지.  