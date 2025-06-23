# Flutter Mobile Wedding Invitation
모바일 청첩장을 쉽게 만들고 공유할 수 있는 Flutter 기반 애플리케이션입니다.

## 📱 프로젝트 소개
이 프로젝트는 결혼을 앞둔 커플들이 모바일 청첩장을 직접 디자인하고 맞춤화하여 친구 및 가족들과 쉽게 공유할 수 있도록 도와주는 애플리케이션입니다. 사용자 친화적인 인터페이스와 풍부한 커스터마이징 옵션을 제공합니다.

## ✨ 주요 기능
### 1. 직관적인 청첩장 에디터
- 드래그 앤 드롭 방식의 위젯 편집
- 실시간 미리보기
- 다양한 위젯 타입 지원 (텍스트, 이미지, 지도 등)

### 2. 페이지 관리 시스템
- 무제한 페이지 생성
- 페이지 순서 변경 (드래그 앤 드롭)
- 페이지 복사 및 삭제 기능

### 3. 사진 갤러리
- 웨딩 사진 슬라이더
- 이미지 확대 보기
- 다양한 레이아웃 옵션

### 4. 오시는 길 안내
- 지도 통합 (Flutter Map)
- 대중교통 및 자가용 경로 안내
- 주요 네비게이션 앱 연동 (카카오맵, 네이버맵, 구글맵)

### 5. 축하 메시지 기능
- 실시간 방명록
- 이모티콘 지원
- 메시지 좋아요 기능

### 6. 공유 기능
- QR 코드 생성
- 카카오톡, 라인 등 SNS 공유
- 개인화된 링크 생성

## 🛠 기술 스택
- **프론트엔드**: Flutter 3.4.1+
- **백엔드**: Supabase (준비 중)
- **저장소**: Supabase Storage
- **인증**: Supabase Auth
- **지도**: Flutter Map
- **상태 관리**: Provider
- **아키텍처**: MVVM (Model-View-ViewModel)

## 📋 필수 요구사항
- Flutter 3.4.1 이상
- Dart 2.17.0 이상
- 인터넷 연결

## 🚀 설치 및 실행 방법

### 1. 저장소 복제
```bash
git clone https://github.com/daegyujeong/wedding-invitation.git
cd wedding-invitation
```

### 2. 의존성 설치
```bash
flutter pub get
```

### 3. 앱 실행
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome
```

## 📁 프로젝트 구조
```
lib/
├── core/                    # 핵심 유틸리티 및 상수
├── data/                    # 데이터 레이어
│   ├── models/             # 데이터 모델
│   ├── repositories/       # 데이터 저장소
│   └── services/           # 외부 서비스 연동
├── features/               # 기능별 모듈
├── presentation/           # UI 레이어
│   ├── screens/           # 화면 컴포넌트
│   ├── viewmodels/        # 뷰모델 (비즈니스 로직)
│   └── widgets/           # 재사용 가능한 위젯
└── main.dart              # 앱 진입점
```

## 🐛 알려진 이슈 및 해결 방법

### 1. Asset 이미지 누락
현재 placeholder 이미지를 사용하고 있습니다. 실제 이미지를 추가하려면:
```bash
# assets/images/ 폴더에 이미지 추가
# pubspec.yaml에 이미지 경로 등록
```

### 2. Supabase 초기화
Supabase 설정이 필요합니다:
```dart
// lib/main.dart에서 주석 해제
final supabaseService = await SupabaseService.initialize();
```

### 3. 지도 기능
실제 지도 표시를 위해서는 Flutter Map 타일 서버 설정이 필요합니다.

## 🔮 향후 개발 계획
- [ ] Supabase 백엔드 연동
- [ ] 더 많은 템플릿 추가
- [ ] 애니메이션 효과 추가
- [ ] 다국어 지원 확대
- [ ] 오프라인 모드 지원
- [ ] 이미지 최적화 및 압축
- [ ] 초대장 통계 기능
- [ ] 게스트 RSVP 기능

## 🤝 기여하기
프로젝트에 기여하고 싶으시다면:
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 라이센스
이 프로젝트는 MIT 라이센스 하에 배포됩니다.

## 📞 문의
프로젝트에 대한 문의사항이 있으시면 이슈를 생성해주세요.

---

**Made with ❤️ by Daegyu Jeong**