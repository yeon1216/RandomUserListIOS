import Foundation
import RxSwift
import RxCocoa

final class DetailViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let user: Driver<User>
        let error: Driver<Error>
    }
    
    private let user: User
    private let disposeBag = DisposeBag()
    
    init(user: User) {
        self.user = user
    }
    
    func transform(input: Input) -> Output {
        let errorRelay = PublishRelay<Error>()
        
        return Output(
            user: .just(user),
            error: errorRelay.asDriver(onErrorJustReturn: NSError())
        )
    }
} 
