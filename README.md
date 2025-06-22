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
git clone https://github.com/daegyujeong/wedding-invitation.git
cd wedding-invitation
```

2. 의존성 설치
```bash
flutter pub get
```

3. Supabase 설정
   - `lib/core/config/app_config.dart` 파일에서 Supabase URL과 Anon Key 설정
   - Supabase 대시보드에서 테이블 생성 (schema.sql 참고)

4. 앱 실행
```bash
flutter run
```

## 프로젝트 구조

```
lib/
├── core/
│   ├── config/         # 앱 설정
│   ├── models/         # 데이터 모델
│   ├── providers/      # Riverpod providers
│   ├── routes/         # 라우팅
│   ├── services/       # API 서비스
│   ├── utils/          # 유틸리티
│   └── widgets/        # 공통 위젯
└── features/
    ├── home/           # 홈 화면
    ├── templates/      # 템플릿 선택
    ├── editor/         # 청첩장 에디터
    ├── preview/        # 미리보기
    ├── invitation/     # 청첩장 보기
    ├── messages/       # 축하 메시지
    ├── gallery/        # 사진 갤러리
    ├── location/       # 오시는 길
    └── share/          # 공유 기능
```

## 주요 화면

1. **홈 화면**: 환영 메시지와 주요 기능 소개, 내 청첩장 목록
2. **템플릿 선택**: 다양한 디자인 템플릿 제공
3. **에디터**: 기본 정보, 가족 정보, 사진, 스타일 설정
4. **미리보기**: 실제 모바일 화면 미리보기
5. **청첩장 보기**: 완성된 청첩장 화면
6. **축하 메시지**: 방명록 작성 및 보기
7. **사진 갤러리**: 웨딩 사진 슬라이드쇼
8. **오시는 길**: 지도와 교통 정보
9. **공유**: QR 코드 및 SNS 공유 기능

## 향후 개선 사항

- [ ] 더 많은 템플릿 추가
- [ ] 음악 재생 기능
- [ ] 다국어 지원
- [ ] 디데이 카운트다운
- [ ] 참석 여부 확인 기능
- [ ] 축의금 안내
- [ ] 웹 버전 지원

## 라이센스

MIT License

## 문의

GitHub Issues를 통해 문의해주세요.
