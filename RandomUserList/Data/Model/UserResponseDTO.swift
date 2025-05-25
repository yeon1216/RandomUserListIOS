struct UserResponseDTO: Codable {
    let results: [UserDTO]
    let info: InfoDTO
    
    struct InfoDTO: Codable {
        let seed: String
        let results: Int
        let page: Int
        let version: String
    }
}
