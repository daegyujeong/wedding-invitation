Flutter Mobile Wedding Invitation
모바일 청첩장을 쉽게 만들고 공유할 수 있는 Flutter 기반 애플리케이션입니다.

## 프로젝트 소개
이 프로젝트는 결혼을 앞둔 커플들이 모바일 청첩장을 직접 디자인하고 맞춤화하여 친구 및 가족들과 쉽게 공유할 수 있도록 도와주는 애플리케이션입니다. 사용자 친화적인 인터페이스와 풍부한 커스터마이징 옵션을 제공합니다.

## 주요 기능
### 1. 직관적인 청첩장 에디터
- 다양한 템플릿 제공
- 텍스트, 이미지, 색상 등 커스터마이징
- 실시간 미리보기

### 2. 사진 갤러리
- 웨딩 사진 슬라이더
- 이미지 확대 보기
- 다양한 레이아웃 옵션

### 3. 오시는 길 안내 (🆕 Multi-Map Support)
- **Google Maps, Naver Maps, Kakao Maps 지원**
- 지도 제공자 선택 가능
- 대중교통 및 자가용 경로 안내
- 주요 네비게이션 앱 연동 (카카오맵, 네이버맵, 구글맵)

### 4. 축하 메시지 기능
- 실시간 방명록
- 이모티콘 지원
- 메시지 좋아요 기능

### 5. 공유 및 초대 기능
- 카카오톡, 라인 등 SNS 공유
- QR 코드 생성
- 개인화된 링크 생성

## 기술 스택
- **프론트엔드**: Flutter
- **백엔드**: Supabase
- **저장소**: Supabase Storage
- **인증**: Supabase Auth
- **지도**: Google Maps, Naver Maps, Kakao Maps
- **상태 관리**: Provider, Riverpod
- **아키텍처**: MVVM (Model-View-ViewModel)

## 개발 환경 설정

### 필수 요구사항
- Flutter 3.0.0 이상
- Dart 2.17.0 이상
- 인터넷 연결

### 설치 방법

1. 저장소 복제
```bash
git clone https://github.com/daegyujeong/wedding-invitation.git
cd wedding-invitation
```

2. 환경 변수 설정
```bash
cp .env.example .env
# .env 파일을 열어 실제 API 키 입력
```

3. 의존성 설치
```bash
flutter pub get
```

4. 지도 API 설정 (자세한 내용은 [MAP_SETUP_GUIDE.md](docs/MAP_SETUP_GUIDE.md) 참조)
   - Google Maps API Key 발급 및 설정
   - Naver Maps Client ID 발급 및 설정
   - Kakao Maps JavaScript Key 발급 및 설정

5. 앱 실행
```bash
flutter run
```

## 지도 위젯 사용 방법

### 에디터에서 지도 추가하기
1. 위젯 선택 화면에서 "지도" 위젯 선택
2. 지도 편집 다이얼로그에서 설정:
   - **지도 제공자**: Google Maps, Naver Maps, Kakao Maps 중 선택
   - **장소명**: 결혼식장 이름 입력
   - **좌표**: 위도, 경도 입력 (또는 주요 장소 선택)
   - **옵션**: 길찾기 버튼, 지도 컨트롤 표시 여부

### 코드에서 직접 사용
```dart
MultiMapWidget(
  latitude: 37.5665,
  longitude: 126.9780,
  venue: '서울시청',
  provider: MapProvider.google, // .naver, .kakao
  showControls: true,
  showDirections: true,
  height: 300,
)
```

## 프로젝트 구조
```
lib/
├── main.dart                 # 앱 진입점
├── core/                     # 핵심 유틸리티
│   └── config/              # 환경 설정
├── data/                     # 데이터 레이어
│   └── models/              # 데이터 모델
├── features/                 # 기능별 모듈
│   ├── gallery/             # 갤러리 기능
│   ├── location/            # 위치/지도 기능
│   ├── messages/            # 메시지 기능
│   └── share/               # 공유 기능
└── presentation/             # UI 레이어
    ├── screens/             # 화면
    ├── widgets/             # 위젯
    └── viewmodels/          # 뷰모델
```

## 기여하기
프로젝트에 기여하고 싶으시다면:
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스
이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 문의
프로젝트 관련 문의사항이 있으시면 이슈를 생성해주세요.
