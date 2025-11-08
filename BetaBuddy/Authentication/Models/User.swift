//
//  User.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/7/25.
//

import Foundation

@Observable class User: Equatable, Identifiable {
    var id: String { userId }
    var userId: String
    var username: String
    var email: String
    var password: String?

    
    var friends: [String] = []
    var myPosts: [String] = []
    var myStats: Statistics = Statistics()


    
    init(userId: String, username: String, email: String, password: String? = nil) {
        self.userId = userId
        self.username = username
        self.email = email
        self.password = password
    }

    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.userId == rhs.userId && lhs.username == rhs.username && lhs.email == rhs.email
    }
}
