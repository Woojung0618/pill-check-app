# 영양제 복용 체크 앱 (Pill Check App)

매일 영양제 복용 여부를 체크하고 관리하는 Flutter 앱입니다.

## 📱 주요 기능

### 0. 회원관리
- **비로그인 상태 지원**
  - 앱 설치 후 즉시 사용 가능 (회원가입 불필요)
  - 로컬 스토리지(Hive/SQLite)에 데이터 저장
  - 모든 기능을 비로그인 상태에서도 사용 가능
- **로그인 및 회원가입**
  - Firebase Authentication을 이용한 로그인 및 회원관리
  - 이메일/구글 로그인 지원
  - 로그인 시 로컬 데이터 자동 마이그레이션
    - 로컬에 저장된 영양제 정보 → Firestore로 이동
    - 로컬에 저장된 복용 기록 → Firestore로 이동
    - 마이그레이션 완료 후 로컬 데이터 정리
- **데이터 동기화**
  - 로그인 상태: Firestore를 메인 저장소로 사용
  - 비로그인 상태: 로컬 스토리지를 메인 저장소로 사용
  - 로그인 후 자동으로 클라우드 동기화

### 1. 영양제 등록 기능
- **입력 필드**
  - 영양제 이름 (필수)
  - 색상 선택 (캡슐/정/분말 컬러 팔레트)
  - 브랜드 (선택)
  - 아이콘 선택 (동글/각진/의약품 모양 등)
- **복용 설정**
  - 하루 복용 횟수 설정 (기본 1회)
  - 알림 설정 (선택)
    - 알림 주기 설정
    - 알림 시간 설정

### 2. 달력뷰 + 체크 기능
#### 🗓 달력 영역 (상단)
- Monthly calendar view
- 날짜 선택 시 하단 체크 리스트에 해당 날짜의 복용 상태 표시
- 체크 여부를 색상/아이콘으로 시각화 (●, ✓ 등)

#### ✔ 체크 리스트 영역 (하단)
- "오늘 챙겨야 할 영양제 목록" 표시
- 형태 예시:
  ```
  [ ] 비타민D (노란색)
  [x] 마그네슘 (하늘색)
  [ ] 오메가3 (투명 캡슐)
  ```
- 체크 시:
  - DB에 섭취 기록 저장
  - 애니메이션 효과 (살짝 통통 튀는 동작)로 UX 향상

### 3. 홈 위젯 (iOS/Android)
- **3가지 사이즈 지원**: Small, Medium, Large
- 위젯에서 오늘 하루의 복용 상태 확인 가능
- 빠른 체크 기능 (위젯에서 직접 체크 가능)

### 4. 설정 화면
- 프로필 관리
- 알림 설정
- 데이터 백업/복원
- 앱 정보

## 🎨 화면 구성

### 1. 홈 화면
- 오늘 날짜 표시
- 오늘의 복용률 % 표시
- 바 형태의 복용률 그래프
- "오늘의 영양제 체크" 버튼
- 최근 7일 복용률 그래프

### 2. 영양제 등록 화면
- 영양제 이름 입력 필드
- 색상 선택 팔레트
- 브랜드 입력 필드 (optional)
- 복용 횟수 선택 (1회 ~ 5회)
- 알림 설정 토글 및 시간 선택
- 저장 버튼

### 3. 달력 + 체크 화면
- **상단**: Calendar View
  - 월별 달력 표시
  - 날짜별 복용 상태 시각화
- **하단**: 오늘의 영양제 체크 리스트
  - 영양제별 색상 및 아이콘 표시
  - 체크박스로 복용 여부 체크
  - 체크 시 애니메이션 효과

## 🛠 기술 스택

### Backend
- **Firebase Authentication**: 사용자 인증
- **Cloud Firestore**: 영양제 정보 및 복용 기록 저장
- **Firebase Cloud Messaging**: 푸시 알림

### Frontend
- **Flutter**: 크로스 플랫폼 앱 개발
- **State Management**: Provider 또는 Riverpod
- **Local Database**: Hive 또는 SQLite
  - 비로그인 상태: 메인 데이터 저장소
  - 로그인 상태: 오프라인 캐시 및 동기화 대기 데이터 저장

### 주요 패키지 (예상)
- `firebase_auth`: Firebase 인증
- `cloud_firestore`: Firestore 데이터베이스
- `table_calendar`: 달력 뷰
- `flutter_local_notifications`: 로컬 알림
- `hive` 또는 `sqflite`: 로컬 데이터베이스
- `provider` 또는 `riverpod`: 상태 관리
- `flutter_svg`: 아이콘 및 이미지

## 📂 프로젝트 구조 (예상)

```
lib/
├── main.dart
├── models/
│   ├── pill.dart          # 영양제 모델
│   ├── intake_record.dart # 복용 기록 모델
│   └── user.dart          # 사용자 모델
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── pill_register_screen.dart
│   ├── calendar_check_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── pill_card.dart
│   ├── calendar_widget.dart
│   ├── intake_rate_chart.dart
│   └── pill_check_list.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── notification_service.dart
│   ├── local_storage_service.dart
│   ├── data_migration_service.dart  # 로컬 → Firestore 마이그레이션
│   └── data_sync_service.dart        # 데이터 동기화 관리
├── providers/
│   ├── pill_provider.dart
│   └── intake_provider.dart
└── utils/
    ├── constants.dart
    └── helpers.dart
```

## 🚀 개발 단계

### Phase 1: 기본 구조 및 로컬 스토리지
1. 프로젝트 초기 설정
2. 로컬 데이터베이스 설정 (Hive/SQLite)
3. 로컬 스토리지 서비스 구현
4. 비로그인 상태에서 동작하는 기본 구조
5. 기본 네비게이션 구조

### Phase 2: 영양제 관리 (로컬 우선)
1. 영양제 등록 화면 구현
2. 로컬 스토리지에 영양제 데이터 저장
3. 영양제 목록 조회 (로컬에서)
4. 로그인 상태 확인 로직 추가

### Phase 3: Firebase 연동 및 인증
1. Firebase 프로젝트 설정
2. Firebase Authentication 연동
3. 로그인/회원가입 화면 구현
4. 인증 상태 관리 (로그인/비로그인)

### Phase 4: 데이터 마이그레이션
1. 데이터 마이그레이션 서비스 구현
   - 로컬 → Firestore 데이터 이동 로직
   - 중복 데이터 방지 로직
   - 마이그레이션 진행 상태 표시
2. 로그인 시 자동 마이그레이션 트리거
3. 마이그레이션 완료 후 로컬 데이터 정리
4. 에러 처리 및 재시도 로직

### Phase 5: 이중 저장소 지원
1. Firestore 서비스 구현
2. 로그인 상태에 따른 저장소 선택 로직
   - 비로그인: 로컬 스토리지 사용
   - 로그인: Firestore 사용 (로컬은 캐시)
3. 데이터 동기화 서비스 구현
4. 영양제 CRUD 작업을 저장소에 맞게 처리

### Phase 6: 달력 및 체크 기능
1. 달력 뷰 구현
2. 체크 리스트 화면 구현
3. 복용 기록 저장 및 조회 (로컬/Firestore)
4. 날짜별 복용 상태 표시

### Phase 7: 홈 화면 및 통계
1. 홈 화면 UI 구현
2. 복용률 계산 로직
3. 그래프 표시
4. 로그인/비로그인 상태에 따른 UI 분기

### Phase 8: 알림 및 위젯
1. 로컬 알림 구현
2. 홈 위젯 구현 (iOS/Android)

### Phase 9: 설정 및 최적화
1. 설정 화면 구현
2. 데이터 백업/복원
3. 성능 최적화
4. 오프라인 지원
5. 로그아웃 시 데이터 처리 (로컬 유지 또는 삭제 선택)

## 🔄 데이터 동기화 전략

### 비로그인 상태
- **저장소**: 로컬 스토리지 (Hive/SQLite)
- **데이터 흐름**: 
  - 영양제 등록 → 로컬 저장
  - 복용 기록 → 로컬 저장
  - 모든 조회 → 로컬에서 조회
- **특징**: 
  - 즉시 사용 가능
  - 오프라인에서도 완전히 동작
  - 기기 변경 시 데이터 손실 가능

### 로그인 상태
- **저장소**: Firestore (메인), 로컬 스토리지 (캐시)
- **데이터 흐름**:
  - 영양제 등록 → Firestore 저장 → 로컬 캐시 업데이트
  - 복용 기록 → Firestore 저장 → 로컬 캐시 업데이트
  - 조회 → Firestore 우선, 오프라인 시 로컬 캐시 사용
- **특징**:
  - 클라우드 동기화
  - 여러 기기에서 동일한 데이터 접근
  - 오프라인 지원 (Firestore 오프라인 캐시)

### 로그인 시 마이그레이션 프로세스
1. **사용자 로그인 성공**
2. **로컬 데이터 확인**
   - 로컬에 영양제 데이터 존재 여부 확인
   - 로컬에 복용 기록 존재 여부 확인
3. **마이그레이션 시작**
   - 진행 상태 표시 (로딩 인디케이터)
   - 영양제 데이터 마이그레이션
     - Firestore에 동일한 영양제가 있는지 확인
     - 없으면 추가, 있으면 병합 또는 스킵
   - 복용 기록 마이그레이션
     - 날짜별로 중복 체크
     - 기존 기록과 병합
4. **마이그레이션 완료**
   - 로컬 데이터 정리 (선택적)
   - Firestore 데이터로 전환
   - 사용자에게 완료 알림

### 마이그레이션 시나리오
```
시나리오 1: 완전히 새로운 로그인
- 로컬에 데이터 있음 → Firestore로 모두 이동
- Firestore에 기존 데이터 없음 → 그대로 추가

시나리오 2: 기존 계정 재로그인
- 로컬에 데이터 있음
- Firestore에도 데이터 있음
- 병합 전략:
  * 영양제: 이름 기준으로 중복 체크, 없으면 추가
  * 복용 기록: 날짜 + 영양제 ID 기준으로 중복 체크, 없으면 추가
```

## 📝 데이터 모델 설계

### Pill (영양제)
```dart
{
  id: String,
  userId: String,
  name: String,
  color: String,
  brand: String?,
  icon: String,
  dailyIntakeCount: int,
  notificationEnabled: bool,
  notificationTimes: List<TimeOfDay>?,
  createdAt: DateTime,
  updatedAt: DateTime
}
```

### IntakeRecord (복용 기록)
```dart
{
  id: String,
  userId: String?,  // 비로그인 상태에서는 null
  pillId: String,
  date: DateTime,
  intakeCount: int,  // 하루 중 몇 번째 복용인지
  checkedAt: DateTime,
  createdAt: DateTime,
  isLocal: bool?     // 로컬에서 생성된 데이터인지 표시
}
```

### 마이그레이션 메타데이터
```dart
{
  userId: String,
  migrationCompleted: bool,
  migratedAt: DateTime?,
  localDataExists: bool,
  migrationStatus: String  // 'pending', 'in_progress', 'completed', 'failed'
}
```

## 🎯 향후 개선 사항
- 복용 통계 및 인사이트 제공
- 영양제 사진 등록 기능
- 복용 패턴 분석
- 다크 모드 지원
- 다국어 지원
