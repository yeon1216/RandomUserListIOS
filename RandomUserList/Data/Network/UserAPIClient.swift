import Foundation
import RxSwift

final class UserAPIClient {
    private let baseURL = "https://randomuser.me/api/"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchUsers(page: Int, gender: Gender) -> Observable<UserResponseDTO> {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "results", value: "10")
        ]
        
        if gender != .all {
            components.queryItems?.append(URLQueryItem(name: "gender", value: gender.rawValue))
        }
        
        guard let url = components.url else {
            return .error(NSError(domain: "UserAPIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        print("yeon :: UserAPIClient :: fetchUsers :: url: \(url)")
        
        return session.rx.data(request: URLRequest(url: url))
            .map { data in
                let decoder = JSONDecoder()
                return try decoder.decode(UserResponseDTO.self, from: data)
            }
    }
    
}
