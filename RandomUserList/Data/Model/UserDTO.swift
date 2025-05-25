struct UserDTO: Codable {
    let gender: String
    let name: NameDTO
    let email: String
    let picture: PictureDTO
    let location: LocationDTO
    let login: LoginDTO
    
    struct NameDTO: Codable {
        let title: String
        let first: String
        let last: String
    }
    
    struct PictureDTO: Codable {
        let large: String
        let medium: String
        let thumbnail: String
    }
    
    struct LocationDTO: Codable {
        let street: StreetDTO
        let city: String
        let state: String
        let country: String
        
        struct StreetDTO: Codable {
            let number: Int
            let name: String
        }
    }
    
    struct LoginDTO: Codable {
        let uuid: String
        let username: String
    }
    
    func toDomain() -> User {
        return User(
            id: login.uuid,
            gender: gender,
            name: User.Name(
                title: name.title,
                first: name.first,
                last: name.last
            ),
            email: email,
            picture: User.Picture(
                large: picture.large,
                medium: picture.medium,
                thumbnail: picture.thumbnail
            ),
            location: User.Location(
                street: User.Location.Street(
                    number: location.street.number,
                    name: location.street.name
                ),
                city: location.city,
                state: location.state,
                country: location.country
            ),
            login: User.Login(
                uuid: login.uuid,
                username: login.username
            )
        )
    }
} 
