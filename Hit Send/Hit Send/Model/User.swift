//
//  User.swift
//  Hit Send
//
//  Created by Abdul Moiz on 20/07/2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Monkey D Luffy", email: "test@gmail.com")
}
