import RxSwift

protocol UserRepository {
    func fetchUsers(page: Int, gender: Gender) -> Observable<[User]>
} 

final class UserRepositoryImpl: UserRepository {
    private let apiClient: UserAPIClient
    
    init(apiClient: UserAPIClient) {
        self.apiClient = apiClient
    }
    
    func fetchUsers(page: Int, gender: Gender) -> Observable<[User]> {
        return apiClient.fetchUsers(page: page, gender: gender)
            .map { response in
                response.results.map { $0.toDomain() }
            }
    }
    
}
