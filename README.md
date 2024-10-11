# WeatherSearch
OpenWeather API를 이용해 날씨를 보고자하는 리스트와 선택한 도시의 날씨를 보여주는 프로젝트

### 🧑‍💻 주요 기능 (Features)

날씨 검색: 사용자가 도시 이름으로 날씨 정보를 검색할 수 있습니다.
현재 날씨: 선택한 도시의 현재 기온, 습도, 구름 상태, 바람 속도 등의 정보를 제공합니다.
5일 간의 날씨 예보: 사용자가 검색한 도시에 대해 3시간 간격으로 5일 동안의 날씨 예보를 확인할 수 있습니다.
지도 표시: 선택된 도시의 지리적 위치를 지도 위에 표시합니다.
한국 표준시 지원: UTC 시간을 한국 표준 시간으로 변환하여 정확한 시간 정보를 제공합니다.
애니메이션 로딩 스크린: 로딩 시 애니메이션 효과와 함께 데이터가 불러와집니다.


### 🛠️ 기술 스택 (Tech Stack)

언어: Swift
UI: UIKit, SnapKit
아키텍처: MVVM (Model-View-ViewModel), Clean Architecture
비동기 처리: RxSwift, async/await
API 호출: Alamofire
의존성 관리: SPM
기타: RxCocoa



### 🗂 프로젝트 구조 (Project Structure)



```
WeatherSearch/
│
├── WeatherSearch.xcodeproj          # Xcode 프로젝트 파일
├── Models/                          # 데이터 모델
├── Views/                           # 뷰 관련 파일 (UIView, UITableViewCell 등)
├── ViewModels/                      # MVVM 패턴에 사용되는 ViewModel 파일들
├── ViewController/                  # UI와 비즈니스 로직을 연결
├── Network/                         # API 통신 및 데이터 로드 관련 파일
├── Coordinators/                    # 앱 내 화면 전환을 관리하는 Coordinator 파일
├── Resources/                       # 이미지, JSON 파일 등 리소스
└── Supporting Files/                # 앱 설정 및 지원 파일
```


## 📱 화면 구성 (Screens)


로딩 화면 (Loading Screen): 앱 실행 시 데이터를 불러오는 동안 애니메이션이 표시됩니다.
메인 화면 (Weather Screen): 날씨 데이터를 보여주는 메인 화면으로, 도시를 검색하고 날씨 데이터를 확인할 수 있습니다.
검색 화면 (Search Screen): 검색바를 통해 도시 리스트에서 도시를 선택하고, 해당 도시의 날씨 정보를 확인할 수 있습니다.
