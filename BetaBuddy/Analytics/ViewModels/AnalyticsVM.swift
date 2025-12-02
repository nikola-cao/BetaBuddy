//
//  AnalyticsVM.swift
//  BetaBuddy
//
//  Analytics View Model to fetch and compute user statistics from posts
//

import Foundation
import Firebase

@Observable
class AnalyticsVM {
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Computed statistics
    var totalClimbs: Int = 0
    var gradeBreakdown: [Grades: Int] = [:]
    var mostVisitedGym: String = "N/A"
    var gymVisits: [String: Int] = [:]
    
    // Raw posts data
    private var userPosts: [PostModel] = []
    
    // Fetch all posts for a specific user and compute analytics
    func fetchUserAnalytics(userID: String) {
        isLoading = true
        errorMessage = nil
        
        Firebase.db.collection("posts")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching user posts for analytics: \(error)")
                    self.errorMessage = "Failed to load analytics"
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    self.isLoading = false
                    return
                }
                
                // Parse documents into PostModel objects
                self.userPosts = documents.compactMap { document in
                    let data = document.data()
                    
                    guard let postID = data["postID"] as? String,
                          let userID = data["userID"] as? String,
                          let username = data["username"] as? String,
                          let attempts = data["attempts"] as? Int,
                          let dateString = data["date"] as? String,
                          let gradeString = data["grade"] as? String,
                          let grade = Grades(rawValue: gradeString),
                          let gymName = data["gymName"] as? String,
                          let location = data["location"] as? String else {
                        print("Failed to parse post document")
                        return nil
                    }
                    
                    let notes = data["notes"] as? String ?? ""
                    
                    // Parse date string (format: "yyyy-MM-dd")
                    let dateComponents = dateString.split(separator: "-")
                    guard dateComponents.count == 3,
                          let year = Int(dateComponents[0]),
                          let month = Int(dateComponents[1]),
                          let day = Int(dateComponents[2]) else {
                        print("Failed to parse date: \(dateString)")
                        return nil
                    }
                    
                    let date = PostDate(year: year, month: month, day: day)
                    
                    return PostModel(
                        postID: postID,
                        userID: userID,
                        username: username,
                        attempts: attempts,
                        date: date,
                        grade: grade,
                        gymName: gymName,
                        location: location,
                        notes: notes
                    )
                }
                
                // Compute analytics
                self.computeAnalytics()
                self.isLoading = false
            }
    }
    
    // Compute analytics from the fetched posts
    private func computeAnalytics() {
        // Total climbs
        totalClimbs = userPosts.count
        
        // Grade breakdown
        gradeBreakdown = [:]
        for post in userPosts {
            gradeBreakdown[post.grade, default: 0] += 1
        }
        
        // Gym visits
        gymVisits = [:]
        for post in userPosts {
            gymVisits[post.gymName, default: 0] += 1
        }
        
        // Most visited gym
        if let mostVisited = gymVisits.max(by: { $0.value < $1.value }) {
            mostVisitedGym = mostVisited.key
        } else {
            mostVisitedGym = "N/A"
        }
    }
    
    // Get grade breakdown sorted by grade difficulty
    func getSortedGradeBreakdown() -> [(Grades, Int)] {
        let gradeOrder = Grades.allCases
        return gradeBreakdown
            .sorted { gradeOrder.firstIndex(of: $0.key)! < gradeOrder.firstIndex(of: $1.key)! }
    }
}
