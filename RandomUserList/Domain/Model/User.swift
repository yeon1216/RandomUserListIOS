import Foundation

struct User {
    let id: String
    let gender: String
    let name: Name
    let email: String
    let picture: Picture
    let location: Location
    let login: Login
    
    struct Name {
        let title: String
        let first: String
        let last: String
        
        var fullName: String {
            return "\(first) \(last)"
        }
    }
    
    struct Picture {
        let large: String
        let medium: String
        let thumbnail: String
    }
    
    struct Location {
        let street: Street
        let city: String
        let state: String
        let country: String
        
        struct Street {
            let number: Int
            let name: String
        }
        
        var formattedAddress: String {
            return "\(street.number) \(street.name), \(city), \(state), \(country)"
        }
    }
    
    struct Login {
        let uuid: String
        let username: String
    }
}

enum Gender: String {
    case male
    case female
    case all
}
