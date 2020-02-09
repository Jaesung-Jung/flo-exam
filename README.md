# Flow Exam

## 작성자

- 정재성 ([jerks@naver.com](mailto://jerks@naver.com))

---

## 개발환경

- Swift 5.1
- Deployment Target: iOS 10.0

---

## 아키텍처

- ReactorKit (Unidirectional Data Flow + MVVM)

---

## Dependency & Open Source

- Then - <https://github.com/devxoul/Then>
- RxSwift - <https://github.com/ReactiveX/RxSwift>
- RxCocoa - <https://github.com/ReactiveX/RxSwift>
- ReactorKit - <https://github.com/ReactorKit/ReactorKit>
- Cartography - <https://github.com/robb/Cartography>
- SwiftLint - <https://github.com/realm/SwiftLint>
- Quick - <https://github.com/Quick/Quick>
- Nimble - <https://github.com/Quick/Nimble>
- Stubber - <https://github.com/devxoul/Stubber>
- RxBlocking - <https://github.com/ReactiveX/RxSwift>

---

## 요구사항

- 플래시 스크린

  - [x] ~~제공되는 이미지를 2초간 노출 후 음악 재생 화면으로 전환시킵니다.~~

- 음악 재생 화면

  - [x] ~~주어진 노래의 재생 화면이 노출됩니다.~~
  - [x] ~~앨범 커버 이미지, 앨범명, 아티스트명, 곡명이 함께 보여야 합니다.~~
  - [x] ~~재생 버튼을 누르면 음악이 재생됩니다. (1개의 음악 파일을 제공할 예정)~~
  - [x] ~~재생 시 현재 재생되고 있는 구간대의 가사가 실시간으로 표시됩니다.~~
  - [x] ~~정지 버튼을 누르면 재생 중이던 음악이 멈춥니다.~~
  - [x] ~~seekbar를 조작하여 재생 시작 시점을 이동시킬 수 있습니다.~~

- 전체 가사 보기 화면

  - [x] ~~전체 가사가 띄워진 화면이 있으며, 특정 가사 부분으로 이동할 수 있는 토글 버튼이 존재합니다.~~
  - [x] ~~토글 버튼 on: 특정 가사 터치 시 해당 구간부터 재생~~
  - [x] ~~토글 버튼 off: 특정 가사 터치 시 전체 가사 화면 닫기~~
  - [x] ~~전체 가사 화면 닫기 버튼이 있습니다.~~
  - [x] ~~현재 재생 중인 부분의 가사가 하이라이팅 됩니다.~~

---

## 참조

- AVPlayer - <https://developer.apple.com/documentation/avfoundation/avplayer>
- Design Resource - <https://www.flaticon.com>
- UIKit Preview - <https://nshipster.com/swiftui-previews>
- Auto memoization - <https://devstreaming-cdn.apple.com/videos/wwdc/2014/404xxdxsstkaqjb/404/404_advanced_swift.pdf>
