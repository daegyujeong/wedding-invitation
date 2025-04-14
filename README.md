# Flutter Mobile Wedding Invitation

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

### 3. 오시는 길 안내
- 지도 통합
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
- **지도**: Flutter Map
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
git clone https://github.com/your-username/flutter-wedding-invitation.git
cd flutter-wedding-invitation

lib/
  ├── main.dart                     # 앱 진입점
  ├── app/                          # 앱 관련 설정
  │    ├── di/                      # 의존성 주입
  │    ├── locator.dart             # 서비스 로케이터
  │    └── app.dart                 # 앱 설정 및 라우팅
  ├── core/                         # 핵심 기능
  │    ├── constants/               # 상수 정의
  │    ├── exceptions/              # 예외 처리
  │    ├── services/                # 서비스 인터페이스
  │    │    ├── storage_service.dart
  │    │    ├── auth_service.dart
  │    │    └── navigation_service.dart
  │    └── utils/                   # 유틸리티 함수
  ├── data/                         # 데이터 레이어
  │    ├── datasources/             # 데이터 소스
  │    │    ├── remote/
  │    │    └── local/
  │    ├── repositories/            # 저장소 구현체
  │    └── models/                  # 데이터 모델
  ├── domain/                       # 도메인 레이어
  │    ├── entities/                # 비즈니스 엔티티
  │    ├── repositories/            # 저장소 인터페이스
  │    └── usecases/                # 비즈니스 유스케이스
  ├── presentation/                 # 프레젠테이션 레이어
  │    ├── common/                  # 공통 위젯
  │    ├── screens/                 # 화면 구현
  │    │    ├── home/               # 홈 화면
  │    │    │    ├── home_screen.dart
  │    │    │    └── home_viewmodel.dart
  │    │    ├── gallery/            # 갤러리 화면
  │    │    │    ├── gallery_screen.dart
  │    │    │    └── gallery_viewmodel.dart
  │    │    ├── location/           # 오시는 길 화면
  │    │    │    ├── location_screen.dart
  │    │    │    └── location_viewmodel.dart
  │    │    ├── messages/           # 축하 메시지 화면
  │    │    │    ├── message_screen.dart
  │    │    │    └── message_viewmodel.dart
  │    │    └── editor/             # 에디터 화면
  │    │         ├── editor_screen.dart
  │    │         └── editor_viewmodel.dart
  │    └── viewmodels/              # 공통 뷰모델
  └── infrastructure/               # 인프라 레이어
       ├── services/                # 서비스 구현체
       └── repositories/            # 저장소 구현체