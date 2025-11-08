//
//  PostModel.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/8/25.
//

import Foundation

struct PostModel: Identifiable {
    
    var id: String {postID}
    var postID: String
    var userID: String
    var username: String
    var attempts: Int
    var date: PostDate
    var grade: Grades
    var gymName: String
    var location: String
    var notes: String
    
    init(postID: String, userID: String, username: String, attempts: Int, date: PostDate, grade: Grades, gymName: String, location: String, notes: String) {
        
        self.postID = postID
        self.userID = userID
        self.username = username
        self.attempts = attempts
        self.date = date
        self.grade = grade
        self.gymName = gymName
        self.location = location
        self.notes = notes
    }
}

struct PostDate {
    
    var year: Int
    var month: Int
    var day: Int
    
    init(year: Int, month: Int, day: Int) {
        
        self.year = year
        self.month = month
        self.day = day
    }
    
    func toString() -> String {
        
        return "\(year)-\(month)-\(day)"
    }
}
