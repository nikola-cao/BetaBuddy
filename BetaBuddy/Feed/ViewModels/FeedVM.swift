import Foundation
import Firebase

@Observable
class FeedVM {
    
    var posts: [PostModel] = []
    var users: [String] = [] // Now stores userIDs
    var userMap: [String: String] = [:] // Maps userID to username
    var isLoading: Bool = false
    var errorMessage: String?

    func sendFriendRequest(currentUserID: String, otherUserID: String) {
        isLoading = true
        errorMessage = nil
        
        // First, add currentUserID to other user's receivedFriendRequests
        Firebase.db.collection("users").document(otherUserID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching other user: \(error)")
                self.errorMessage = "Failed to send friend request"
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    
                    var receivedRequests = data["receivedFriendRequests"] as? [String] ?? []
                    
                    // Check if request already exists
                    if !receivedRequests.contains(currentUserID) {
                        receivedRequests.append(currentUserID)
                        
                        // Update other user's receivedFriendRequests
                        Firebase.db.collection("users").document(otherUserID).updateData([
                            "receivedFriendRequests": receivedRequests
                        ]) { updateError in
                            
                            if let updateError = updateError {
                                print("Error updating other user's receivedFriendRequests: \(updateError)")
                                self.errorMessage = "Failed to send friend request"
                                self.isLoading = false
                                return
                            }
                            
                            print("Successfully added to other user's receivedFriendRequests")
                            
                            // Now add otherUserID to current user's sentFriendRequests
                            self.addToSentRequests(currentUserID: currentUserID, otherUserID: otherUserID)
                        }
                    } else {
                        print("Friend request already sent")
                        self.isLoading = false
                    }
                } else {
                    print("No data returned from other user document")
                    self.isLoading = false
                }
            } else {
                print("Other user document does not exist")
                self.errorMessage = "User not found"
                self.isLoading = false
            }
        }
    }
    
    private func addToSentRequests(currentUserID: String, otherUserID: String) {
        Firebase.db.collection("users").document(currentUserID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching current user: \(error)")
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    
                    var sentRequests = data["sentFriendRequests"] as? [String] ?? []
                    
                    if !sentRequests.contains(otherUserID) {
                        sentRequests.append(otherUserID)
                        
                        // Update current user's sentFriendRequests
                        Firebase.db.collection("users").document(currentUserID).updateData([
                            "sentFriendRequests": sentRequests
                        ]) { updateError in
                            
                            if let updateError = updateError {
                                print("Error updating current user's sentFriendRequests: \(updateError)")
                            } else {
                                print("Successfully added to current user's sentFriendRequests")
                            }
                            
                            self.isLoading = false
                        }
                    } else {
                        self.isLoading = false
                    }
                }
            } else {
                print("Current user document does not exist")
                self.isLoading = false
            }
        }
    }
    
    func acceptFriendRequest(currentUserID: String, otherUserID: String) {
        isLoading = true
        errorMessage = nil
        
        // First, update current user: move otherUserID from receivedFriendRequests to friends
        Firebase.db.collection("users").document(currentUserID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching current user: \(error)")
                self.errorMessage = "Failed to accept friend request"
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    
                    var receivedRequests = data["receivedFriendRequests"] as? [String] ?? []
                    var friends = data["friends"] as? [String] ?? []
                    
                    // Check if the otherUserID is in receivedFriendRequests
                    if let index = receivedRequests.firstIndex(of: otherUserID) {
                        // Remove from receivedFriendRequests
                        receivedRequests.remove(at: index)
                        
                        // Add to friends if not already there
                        if !friends.contains(otherUserID) {
                            friends.append(otherUserID)
                        }
                        
                        // Update current user's document
                        Firebase.db.collection("users").document(currentUserID).updateData([
                            "receivedFriendRequests": receivedRequests,
                            "friends": friends
                        ]) { updateError in
                            
                            if let updateError = updateError {
                                print("Error updating current user: \(updateError)")
                                self.errorMessage = "Failed to accept friend request"
                                self.isLoading = false
                                return
                            }
                            
                            print("Successfully updated current user's friends and receivedFriendRequests")
                            
                            // Now update the other user
                            self.moveFromSentToFriends(currentUserID: currentUserID, otherUserID: otherUserID)
                        }
                    } else {
                        print("Friend request not found in receivedFriendRequests")
                        self.errorMessage = "Friend request not found"
                        self.isLoading = false
                    }
                } else {
                    print("No data returned from current user document")
                    self.isLoading = false
                }
            } else {
                print("Current user document does not exist")
                self.isLoading = false
            }
        }
    }
    
    private func moveFromSentToFriends(currentUserID: String, otherUserID: String) {
        // Update other user: move currentUserID from sentFriendRequests to friends
        Firebase.db.collection("users").document(otherUserID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching other user: \(error)")
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    
                    var sentRequests = data["sentFriendRequests"] as? [String] ?? []
                    var friends = data["friends"] as? [String] ?? []
                    
                    // Remove from sentFriendRequests
                    if let index = sentRequests.firstIndex(of: currentUserID) {
                        sentRequests.remove(at: index)
                    }
                    
                    // Add to friends if not already there
                    if !friends.contains(currentUserID) {
                        friends.append(currentUserID)
                    }
                    
                    // Update other user's document
                    Firebase.db.collection("users").document(otherUserID).updateData([
                        "sentFriendRequests": sentRequests,
                        "friends": friends
                    ]) { updateError in
                        
                        if let updateError = updateError {
                            print("Error updating other user: \(updateError)")
                        } else {
                            print("Successfully updated other user's friends and sentFriendRequests")
                        }
                        
                        self.isLoading = false
                    }
                } else {
                    print("No data returned from other user document")
                    self.isLoading = false
                }
            } else {
                print("Other user document does not exist")
                self.isLoading = false
            }
        }
    }
    
    func unfriend(currentUserID: String, otherUserID: String) {
        isLoading = true
        errorMessage = nil
        
        // First, remove otherUserID from current user's friends array
        Firebase.db.collection("users").document(currentUserID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching current user: \(error)")
                self.errorMessage = "Failed to unfriend user"
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    
                    var friends = data["friends"] as? [String] ?? []
                    
                    // Remove otherUserID from friends
                    if let index = friends.firstIndex(of: otherUserID) {
                        friends.remove(at: index)
                        
                        // Update current user's friends
                        Firebase.db.collection("users").document(currentUserID).updateData([
                            "friends": friends
                        ]) { updateError in
                            
                            if let updateError = updateError {
                                print("Error updating current user's friends: \(updateError)")
                                self.errorMessage = "Failed to unfriend user"
                                self.isLoading = false
                                return
                            }
                            
                            print("Successfully removed otherUserID from current user's friends")
                            
                            // Now remove currentUserID from other user's friends
                            self.removeFromOtherUserFriends(currentUserID: currentUserID, otherUserID: otherUserID)
                        }
                    } else {
                        print("User not found in friends list")
                        self.errorMessage = "User is not in your friends list"
                        self.isLoading = false
                    }
                } else {
                    print("No data returned from current user document")
                    self.isLoading = false
                }
            } else {
                print("Current user document does not exist")
                self.isLoading = false
            }
        }
    }
    
    private func removeFromOtherUserFriends(currentUserID: String, otherUserID: String) {
        // Remove currentUserID from other user's friends array
        Firebase.db.collection("users").document(otherUserID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching other user: \(error)")
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    
                    var friends = data["friends"] as? [String] ?? []
                    
                    // Remove currentUserID from friends
                    if let index = friends.firstIndex(of: currentUserID) {
                        friends.remove(at: index)
                    }
                    
                    // Update other user's friends
                    Firebase.db.collection("users").document(otherUserID).updateData([
                        "friends": friends
                    ]) { updateError in
                        
                        if let updateError = updateError {
                            print("Error updating other user's friends: \(updateError)")
                        } else {
                            print("Successfully removed currentUserID from other user's friends")
                        }
                        
                        self.isLoading = false
                    }
                } else {
                    print("No data returned from other user document")
                    self.isLoading = false
                }
            } else {
                print("Other user document does not exist")
                self.isLoading = false
            }
        }
    }
    
    func cancelFriendRequest(currentUserID: String, otherUserID: String) {
        isLoading = true
        errorMessage = nil
        
        // First, remove otherUserID from current user's sentFriendRequests
        Firebase.db.collection("users").document(currentUserID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching current user: \(error)")
                self.errorMessage = "Failed to cancel friend request"
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    
                    var sentRequests = data["sentFriendRequests"] as? [String] ?? []
                    
                    // Remove otherUserID from sentFriendRequests
                    if let index = sentRequests.firstIndex(of: otherUserID) {
                        sentRequests.remove(at: index)
                        
                        // Update current user's sentFriendRequests
                        Firebase.db.collection("users").document(currentUserID).updateData([
                            "sentFriendRequests": sentRequests
                        ]) { updateError in
                            
                            if let updateError = updateError {
                                print("Error updating current user's sentFriendRequests: \(updateError)")
                                self.errorMessage = "Failed to cancel friend request"
                                self.isLoading = false
                                return
                            }
                            
                            print("Successfully removed otherUserID from current user's sentFriendRequests")
                            
                            // Now remove currentUserID from other user's receivedFriendRequests
                            self.removeFromReceivedRequests(currentUserID: currentUserID, otherUserID: otherUserID)
                        }
                    } else {
                        print("Friend request not found in sentFriendRequests")
                        self.errorMessage = "Friend request not found"
                        self.isLoading = false
                    }
                } else {
                    print("No data returned from current user document")
                    self.isLoading = false
                }
            } else {
                print("Current user document does not exist")
                self.isLoading = false
            }
        }
    }
    
    private func removeFromReceivedRequests(currentUserID: String, otherUserID: String) {
        // Remove currentUserID from other user's receivedFriendRequests
        Firebase.db.collection("users").document(otherUserID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching other user: \(error)")
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    
                    var receivedRequests = data["receivedFriendRequests"] as? [String] ?? []
                    
                    // Remove currentUserID from receivedFriendRequests
                    if let index = receivedRequests.firstIndex(of: currentUserID) {
                        receivedRequests.remove(at: index)
                    }
                    
                    // Update other user's receivedFriendRequests
                    Firebase.db.collection("users").document(otherUserID).updateData([
                        "receivedFriendRequests": receivedRequests
                    ]) { updateError in
                        
                        if let updateError = updateError {
                            print("Error updating other user's receivedFriendRequests: \(updateError)")
                        } else {
                            print("Successfully removed currentUserID from other user's receivedFriendRequests")
                        }
                        
                        self.isLoading = false
                    }
                } else {
                    print("No data returned from other user document")
                    self.isLoading = false
                }
            } else {
                print("Other user document does not exist")
                self.isLoading = false
            }
        }
    }
    
    func rejectFriendRequest(currentUserID: String, otherUserID: String) {
        isLoading = true
        errorMessage = nil
        
        // First, remove otherUserID from current user's receivedFriendRequests
        Firebase.db.collection("users").document(currentUserID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching current user: \(error)")
                self.errorMessage = "Failed to reject friend request"
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    
                    var receivedRequests = data["receivedFriendRequests"] as? [String] ?? []
                    
                    // Remove otherUserID from receivedFriendRequests
                    if let index = receivedRequests.firstIndex(of: otherUserID) {
                        receivedRequests.remove(at: index)
                        
                        // Update current user's receivedFriendRequests
                        Firebase.db.collection("users").document(currentUserID).updateData([
                            "receivedFriendRequests": receivedRequests
                        ]) { updateError in
                            
                            if let updateError = updateError {
                                print("Error updating current user's receivedFriendRequests: \(updateError)")
                                self.errorMessage = "Failed to reject friend request"
                                self.isLoading = false
                                return
                            }
                            
                            print("Successfully removed otherUserID from current user's receivedFriendRequests")
                            
                            // Now remove currentUserID from other user's sentFriendRequests
                            self.removeFromSentRequests(currentUserID: currentUserID, otherUserID: otherUserID)
                        }
                    } else {
                        print("Friend request not found in receivedFriendRequests")
                        self.errorMessage = "Friend request not found"
                        self.isLoading = false
                    }
                } else {
                    print("No data returned from current user document")
                    self.isLoading = false
                }
            } else {
                print("Current user document does not exist")
                self.isLoading = false
            }
        }
    }
    
    private func removeFromSentRequests(currentUserID: String, otherUserID: String) {
        // Remove currentUserID from other user's sentFriendRequests
        Firebase.db.collection("users").document(otherUserID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching other user: \(error)")
                self.isLoading = false
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    
                    var sentRequests = data["sentFriendRequests"] as? [String] ?? []
                    
                    // Remove currentUserID from sentFriendRequests
                    if let index = sentRequests.firstIndex(of: currentUserID) {
                        sentRequests.remove(at: index)
                    }
                    
                    // Update other user's sentFriendRequests
                    Firebase.db.collection("users").document(otherUserID).updateData([
                        "sentFriendRequests": sentRequests
                    ]) { updateError in
                        
                        if let updateError = updateError {
                            print("Error updating other user's sentFriendRequests: \(updateError)")
                        } else {
                            print("Successfully removed currentUserID from other user's sentFriendRequests")
                        }
                        
                        self.isLoading = false
                    }
                } else {
                    print("No data returned from other user document")
                    self.isLoading = false
                }
            } else {
                print("Other user document does not exist")
                self.isLoading = false
            }
        }
    }
    
    func fetchAllUsers(excludeUserID: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        Firebase.db.collection("users").getDocuments { snapshot, error in
                
            if let error = error {
                print("Error fetching users: \(error)")
                self.errorMessage = "Failed to load users"
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                self.isLoading = false
                return
            }
            
            var tempUsers: [String] = []
            var tempUserMap: [String: String] = [:]
            
            for document in documents {
                let data = document.data()
                
                guard let userID = data["userId"] as? String,
                      let username = data["username"] as? String else {
                    print("Failed to get userId or username from document")
                    continue
                }
                
                // Only exclude the current user
                if let excludeUserID = excludeUserID, userID == excludeUserID {
                    continue
                }
                
                tempUsers.append(userID)
                tempUserMap[userID] = username
            }
            
            self.users = tempUsers
            self.userMap = tempUserMap
            
            print("Successfully loaded \(self.users.count) users with usernames")
            self.isLoading = false
        }
    }
    
    // Fetch all posts from Firebase filtered by current user and friends
    func fetchAllPosts(currentUserID: String, friends: [String]) {
        isLoading = true
        errorMessage = nil
        
        Firebase.db.collection("posts").getDocuments { snapshot, error in
            
            if let error = error {
                print("Error fetching posts: \(error)")
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
                
                // Filter: only show posts from current user or friends
                if userID != currentUserID && !friends.contains(userID) {
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
            
            print("Successfully loaded \(self.posts.count) posts")
            self.isLoading = false
        }
    }
}
