import Foundation
import RxSwift

protocol FetchUsersUseCase {
    func fetchUsers(page: Int, gender: Gender) -> Observable<[User]>
}

final class FetchUsersUseCaseImpl: FetchUsersUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func fetchUsers(page: Int, gender: Gender) -> Observable<[User]> {
        return repository.fetchUsers(page: page, gender: gender)
//            .map { response in
//                response.results
//            }
    }
}
