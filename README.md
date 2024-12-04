## 🏠 기록소 - Memorial House

<img width="77" alt="iOS 16.0" src="https://img.shields.io/badge/iOS-16.0+-silver"> <img width="83" alt="Xcode 16.1" src="https://img.shields.io/badge/Xcode-16.1-blue"> <img width="77" alt="Swift 6.0" src="https://img.shields.io/badge/Swift-6.0+-orange">

<div align="center">
  <img src="https://github.com/user-attachments/assets/aab0f5d8-01b8-4d03-ab3f-9970bcca6ec3" width=900>

  #### 사랑하는 이들과의 소중한 추억을 기록소에서 책으로 엮고 출판해보세요.<br>
  #### 따뜻한 일상부터 특별한 순간까지 추억을 출판하는 곳, **기록소 🏠**

</div>

<br>

## 🍎 기록소 주요 기능
![image](https://github.com/user-attachments/assets/8db2f605-0deb-4627-9ba4-50f029b0cec3)


##

### 🧱 아키텍처

> ### Clean Architecture + MVVM

<img width="742" alt="스크린샷 2024-11-28 오후 11 04 05" src="https://github.com/user-attachments/assets/87b86b8b-2b5f-487e-b648-4eeb80610a36">


- View와 비즈니스 로직 분리를 위해 **MVVM 도입**
  
- 추후 서버 도입 가능성을 고려해 **Repository Pattern을 적용하기 위한 Data Layer 도입**
  
- ViewModel의 복잡도가 증가할 것을 예상하여 **Domain Layer를 두어 Use Case에서 처리**

- 테스트 가능한 구조를 만들기 위해 **Domain Layer에 Repository Interface 구현**

##

### 🛠️ 기술 스택

### Combine
- MVVM 패턴에서 View와 ViewModel의 바인딩을 위해 Combine을 활용했습니다.
- Combine은 First Party 라이브러리라는 점에서 안정성과 지원이 뛰어나며, RxSwift에 비해 성능적인 이점이 있어 RxSwift 대신 Combine을 도입했습니다.

### Swift Concurrency

- 비동기 프로그래밍을 위해 Swift Concurrency(async/await)를 활용하였습니다.
- 기존의 콜백 기반 비동기 프로그래밍은 코드의 깊이가 증가해 가독성을 해치고, completion 호출을 누락하는 등 휴먼 에러가 발생할 가능성이 있었습니다.
- Swift Concurrency을 도입하여 위 단점을 보완하여 코드 가독성과 안정성을 높이고자 했습니다.

### CoreData + FileManager

- Local DB로 Core Data와 FileManager를 함께 활용했습니다.
- Core Data는 책과 페이지 간의 관계를 유지하기 위해 사용하며, 각 페이지는 멀티미디어 데이터를 포함할 수 있습니다.
- 멀티미디어를 Core Data에 직접 저장하면, 책을 펼칠 때 모든 데이터를 한꺼번에 불러와 성능 저하가 발생할 수 있습니다. 이를 방지하기 위해 멀티미디어는 FileManager를 통해 디바이스에 저장하고, Core Data에는 해당 멀티미디어의 URL만 문자열로 저장했습니다.
- 이러한 방식으로 페이지 로드 시 URL만 불러와 메모리 사용을 줄이고, 필요한 멀티미디어는 개별적으로 로드하여 효율성을 높였습니다.

##

### 🔥 우리 팀의 기술적 도전

#### 1. 사진 - [[Phots] 이미지 편집하기](https://kyxxn.notion.site/Photos-9d24b4b1f8d64d809adb946d0543e829?pvs=4)

#### 2. 동영상 - [[AVKit] 내 앨범의 비디오를 업로드하기](https://kyxxn.notion.site/AVKit-1519adb3262680769a14e9dc908400e3?pvs=4)

#### 3. 오디오 - [[AVFAudio] 녹음해서 오디오를 업로드하기](https://kyxxn.notion.site/AVFAudio-1519adb3262680bf84f5dedb7995041d?pvs=4)

#### 4. 멀티 미디어를 담고 있는 TextView 저장하기 - [스냅샷 기반 저장하기](https://kyxxn.notion.site/a8d455af87164a02aa5e4d79e5b3fc92?pvs=4)


##

### 🧑‍🧑‍🧒‍🧒 집주인들

<div align="center">

  <img width="500" alt="image" src="https://github.com/user-attachments/assets/3607a9fb-dd84-4877-83ef-ac8e43e1bc27">

  〰️ 부산 워크샵 단체사진 〰️
  
  <br>

|<img src="https://avatars.githubusercontent.com/u/62226667?v=4" width=150>|<img src="https://avatars.githubusercontent.com/u/129862357?v=4" width=150>|<img src="https://avatars.githubusercontent.com/u/70050038?v=4" width=150>|<img src="https://avatars.githubusercontent.com/u/71179395?v=4" width=150>|
|:-:|:-:|:-:|:-:|
|🎨 김영현|🥇 박효준|👓 안윤철|😽 임정현|
|집주인 내 골드핸즈(= 금손) <br> 초고수 디자이너 <br> 영리아나 그란데 <br> 영카소, 영켈란젤로, 영흐|우리팀 리-더 <br> 발표 초-고수<br> 황금막내 <br> 열정보이🔥 <br> 문서화 장인|데(DevOps) 윤철<br>분위기 메이커<br>아이디어 뱅크 <br> 동의, 인정, 공감 장인 <br> 돌리기 장인 (조리돌림)<br>우리팀 MZ|살아있는 네이버 클로바 <br> 루루 집사 <br> 스티브잡스, 스티브워즈니악,<br>스티브 임정현 Let's Go|
|[@k2645](https://github.com/k2645)|[@kyxxn](https://github.com/kyxxn)|[@yuncheol-AHN](https://github.com/yuncheol-ahn)|[@iceHood](https://github.com/icehood)|

</div>


##

<div align="center">
  
|📓 문서|[Wiki](https://github.com/boostcampwm-2024/iOS10-MemorialHouse/wiki)|[팀 노션](https://kyxxn.notion.site/iOS10-12c9adb32626806c900ad008c85e7dcc?pvs=4)|[그라운드 룰](https://kyxxn.notion.site/12c9adb3262680b28a58dfddd1ed2b59?pvs=4)|[컨벤션](https://kyxxn.notion.site/12c9adb3262680b28a58dfddd1ed2b59?pvs=4)|[회의록](https://kyxxn.notion.site/eb52137ca8374353adbd7fb6926e99e8?pvs=4)|[기획/디자인](https://www.figma.com/design/zgxogGGouOUsshAJkPeT86/MemorialHouse?node-id=0-1&node-type=canvas&t=b4rxjLDdHgzyH6p3-0)|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|

</div>
