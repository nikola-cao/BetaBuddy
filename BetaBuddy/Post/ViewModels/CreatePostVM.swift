//
//  CreatePostVM.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/8/25.
//

import Foundation
import Firebase

@Observable
class CreatePostVM {
    
    func addNewPost(post: PostModel) {
        
        Firebase.db.collection("posts").document(post.postID).setData([
            "postID": post.postID,
            "userID": post.userID,
            "username": post.username,
            "attempts": post.attempts,
            "date": post.date.toString(),
            "grade": post.grade.rawValue,
            "gymName": post.gymName,
            "location": post.location,
            "notes": post.notes
            
        ]) { error in
            
            if let error = error {
                print("Error writing new post: \(error)")
            } else {
                print("Added new post to firebase posts")
                self.addNewPostToUser(post: post)
            }
        }
    }
    
    func addNewPostToUser(post: PostModel) {
        
        // First, fetch the current user's posts
        Firebase.db.collection("users").document(post.userID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching user document: \(error)")
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    // Get existing posts array, or create empty array if none exists
                    var posts = data["myPosts"] as? [String] ?? []
                    print("Successfully retrieved user's posts from firebase. Count: \(posts.count)")
                    
                    // Append the new post ID
                    posts.append(post.postID)
                    
                    // Update the user document with the new posts array
                    Firebase.db.collection("users").document(post.userID).updateData([
                        "myPosts": posts
                    ]) { updateError in
                        
                        if let updateError = updateError {
                            print("Error updating user with new post: \(updateError)")
                        } else {
                            print("Successfully updated user with new post. Total posts: \(posts.count)")
                        }
                    }
                } else {
                    print("No data returned from user document!")
                }
            } else {
                print("User document does not exist for userID: \(post.userID)")
            }
        }
    }
}
