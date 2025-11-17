//
//  ProfileVM.swift
//  BetaBuddy
//
//  Created by Sarvesh Gade on 11/16/25.
//

import Foundation
import Firebase

@Observable
class ProfileVM {
    
    var posts: [PostModel] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Fetch all posts for a specific user
    func fetchUserPosts(userID: String) {
        isLoading = true
        errorMessage = nil
        
        Firebase.db.collection("posts")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Error fetching user posts: \(error)")
                    self.errorMessage = "Failed to load posts"
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    self.isLoading = false
                    return
                }
                
                // Parse documents into PostModel objects
                self.posts = documents.compactMap { document in
                    let data = document.data()
                    
                    guard let postID = data["postID"] as? String,
                          let userID = data["userID"] as? String,
                          let username = data["username"] as? String,
                          let attempts = data["attempts"] as? Int,
                          let dateString = data["date"] as? String,
                          let gradeString = data["grade"] as? String,
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
                    
                    let postDate = PostDate(year: year, month: month, day: day)
                    
                    // Parse grade
                    guard let grade = Grades(rawValue: gradeString) else {
                        print("Failed to parse grade: \(gradeString)")
                        return nil
                    }
                    
                    return PostModel(
                        postID: postID,
                        userID: userID,
                        username: username,
                        attempts: attempts,
                        date: postDate,
                        grade: grade,
                        gymName: gymName,
                        location: location,
                        notes: notes
                    )
                }
                
                // Sort posts by date (most recent first)
                self.posts.sort { post1, post2 in
                    if post1.date.year != post2.date.year {
                        return post1.date.year > post2.date.year
                    } else if post1.date.month != post2.date.month {
                        return post1.date.month > post2.date.month
                    } else {
                        return post1.date.day > post2.date.day
                    }
                }
                
                print("Successfully loaded \(self.posts.count) posts for user")
                self.isLoading = false
            }
    }
    
    // Delete a post
    func deletePost(postID: String, userID: String) {
        isLoading = true
        errorMessage = nil
        
        // First, delete the post from the posts collection
        Firebase.db.collection("posts").document(postID).delete { error in
            
            if let error = error {
                print("Error deleting post: \(error)")
                self.errorMessage = "Failed to delete post"
                self.isLoading = false
                return
            }
            
            print("Successfully deleted post from posts collection")
            
            // Now remove the post ID from the user's myPosts array
            self.removePostFromUser(postID: postID, userID: userID)
        }
    }
    
    private func removePostFromUser(postID: String, userID: String) {
        // Fetch the user document
        Firebase.db.collection("users").document(userID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching user document: \(error)")
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    // Get existing posts array
                    var posts = data["myPosts"] as? [String] ?? []
                    
                    // Remove the post ID
                    if let index = posts.firstIndex(of: postID) {
                        posts.remove(at: index)
                        
                        // Update the user document
                        Firebase.db.collection("users").document(userID).updateData([
                            "myPosts": posts
                        ]) { updateError in
                            
                            if let updateError = updateError {
                                print("Error updating user's myPosts: \(updateError)")
                                self.errorMessage = "Failed to update user profile"
                            } else {
                                print("Successfully removed post from user's myPosts")
                                // Remove the post from local array
                                self.posts.removeAll { $0.postID == postID }
                            }
                            
                            self.isLoading = false
                        }
                    } else {
                        print("Post ID not found in user's myPosts")
                        self.isLoading = false
                    }
                }
            } else {
                print("User document does not exist")
                self.isLoading = false
            }
        }
    }
}
