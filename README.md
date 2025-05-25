# RandomUserList iOS

RandomUser API를 활용한 iOS 사용자 목록 애플리케이션입니다.

## 주요 기능

- RandomUser API를 통한 사용자 목록 표시
- 사용자 상세 정보 조회
- 성별 필터링 (전체/남성/여성)
- 리스트 뷰 스타일 변경 (단일/그리드)
- 사용자 선택 및 삭제 기능
- 무한 스크롤
- Pull Refresh

## 기술 스택

- UI: SanpKit
- 비동기: RxSwift
- 아키텍처 : MVVM + Clean Architecture

- **개발 환경**
  - iOS 15.0+

## 프로젝트 구조

```
RandomUserList/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Domain/
│   ├── Model/
│   │   └── User.swift
│   └── UseCase/
│       └── FetchUsersUseCase.swift
├── Data/
│   ├── Network/
│   │   └── UserAPIClient.swift
│   ├── Repository/
│   │   └── UserRepository.swift
│   └── Model/
│       ├── UserDTO.swift
│       └── UserResponseDTO.swift
└── Presentation/
    ├── Main/
    │   ├── View/
    │   │   ├── MainViewController.swift
    │   │   └── UserCell.swift
    │   ├── ViewModel/
    │   │   └── MainViewModel.swift
    │   └── Coordinator/
    │       └── MainCoordinator.swift
    └── Detail/
        ├── View/
        │   └── DetailViewController.swift
        └── ViewModel/
            └── DetailViewModel.swift
```