//
//  UserUIModel.swift
//  RandomUserList
//
//  Created by ksy on 5/26/25.
//

import Foundation

struct UserUIModel {
    let id: String
    let name: String
    let email: String
    let profileImageURL: String
    let location: String
    let gender: String
    let username: String
    
    init(from user: User) {
        self.id = user.id
        self.name = user.name.fullName
        self.email = user.email
        self.profileImageURL = user.picture.large
        self.location = user.location.formattedAddress
        self.gender = user.gender
        self.username = user.login.username
    }
}

// MARK: - Equatable
extension UserUIModel: Equatable {
    static func == (lhs: UserUIModel, rhs: UserUIModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension UserUIModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

