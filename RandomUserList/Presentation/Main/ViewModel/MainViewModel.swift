import Foundation
import RxSwift
import RxCocoa

final class MainViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Observable<Void>
        let refreshTrigger: Observable<Void>
        let loadMoreTrigger: Observable<Void>
        let genderTabSelected: Observable<Gender>
        let listStyleChanged: Observable<ListStyle>
    }
    
    struct Output {
        let users: Driver<[User]>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
        let listStyle: Driver<ListStyle>
    }
    
    enum ListStyle {
        case single
        case double
    }
    
    private let useCase: FetchUsersUseCase
    private let coordinator: MainCoordinator
    private let disposeBag = DisposeBag()
    private let isLoading = BehaviorRelay<Bool>(value: false)
    private let error = PublishRelay<Error>()
    private let loadedUserIds = BehaviorRelay<Set<String>>(value: [])
    private let deletedUserIds = BehaviorRelay<Set<String>>(value: [])
    private let users = BehaviorRelay<[User]>(value: [])
    
    init(useCase: FetchUsersUseCase, coordinator: MainCoordinator) {
        self.useCase = useCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        let currentPage = BehaviorRelay<Int>(value: 1)
        let currentGender = BehaviorRelay<Gender>(value: .all)
        let currentListStyle = BehaviorRelay<ListStyle>(value: .single)
        
        input.viewDidLoad
            .withLatestFrom(currentGender)
            .flatMapLatest { [weak self] gender -> Observable<[User]> in
                guard let self = self else { return .empty() }
                self.loadedUserIds.accept([])
                return self.fetchUsers(page: 1, gender: gender)
            }
            .bind(to: users)
            .disposed(by: disposeBag)
        
        input.refreshTrigger
            .do(onNext: { _ in currentPage.accept(1) })
            .withLatestFrom(currentGender)
            .flatMapLatest { [weak self] gender -> Observable<[User]> in
                guard let self = self else { return .empty() }
                self.loadedUserIds.accept([])
                return self.fetchUsers(page: 1, gender: gender)
            }
            .bind(to: users)
            .disposed(by: disposeBag)
        
        input.loadMoreTrigger
            .withLatestFrom(Observable.combineLatest(currentPage, currentGender))
            .do(onNext: { page, _ in
                currentPage.accept(page + 1)
            })
            .flatMapLatest { [weak self] page, gender -> Observable<[User]> in
                guard let self = self else { return .empty() }
                return self.fetchUsers(page: page, gender: gender)
            }
            .map { [weak self] newUsers in
                guard let self = self else { return [] }
                var currentUsers = users.value
                let filtered = newUsers.filter { user in
                    !self.loadedUserIds.value.contains(user.id) && !self.deletedUserIds.value.contains(user.id)
                }
                let newIds = Set(filtered.map { $0.id })
                self.loadedUserIds.accept(self.loadedUserIds.value.union(newIds))
                currentUsers.append(contentsOf: filtered)
                return currentUsers
            }
            .bind(to: users)
            .disposed(by: disposeBag)
        
        input.genderTabSelected
            .do(onNext: { gender in
                currentPage.accept(1)
                currentGender.accept(gender)
                self.users.accept([])
                self.loadedUserIds.accept([])
            })
            .flatMapLatest { [weak self] gender -> Observable<[User]> in
                guard let self = self else { return .empty() }
                return self.fetchUsers(page: 1, gender: gender)
            }
            .bind(to: users)
            .disposed(by: disposeBag)
        
        input.listStyleChanged
            .bind(to: currentListStyle)
            .disposed(by: disposeBag)
        
        return Output(
            users: users.asDriver(),
            isLoading: isLoading.asDriver(),
            error: error.asDriver(onErrorJustReturn: NSError()),
            listStyle: currentListStyle.asDriver()
        )
    }
    
    private func fetchUsers(page: Int, gender: Gender) -> Observable<[User]> {
        return useCase.fetchUsers(page: page, gender: gender)
            .do(onSubscribe: { [weak self] in
                self?.isLoading.accept(true)
            }, onDispose: { [weak self] in
                self?.isLoading.accept(false)
            })
            .catch { [weak self] error in
                self?.error.accept(error)
                return .empty()
            }
    }
    
    func deleteUsers(_ usersToDelete: [UserUIModel]) {
        let ids = Set(usersToDelete.map { $0.id })
        deletedUserIds.accept(deletedUserIds.value.union(ids))
        
        var currentUsers = users.value
        currentUsers.removeAll { user in
            ids.contains(user.id)
        }
        users.accept(currentUsers)
    }
    
    func showDetail(user: User) {
        coordinator.showDetail(user: user)
    }
}
