//
//  AuthenticationVM.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/7/25.
//

@preconcurrency import FirebaseAuth
import FirebaseFirestore
import Observation

@Observable class AuthenticationVM {
    
    var errorMessage: String?
    var isLoading = false
    var isLoggedIn = false
    var currentUser: User?
    var auth: Auth
    
    init() {
        self.auth = Auth.auth()
    }
    
    @MainActor
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil // Clear previous errors
        
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let user = authResult.user
            
            print("✅ Signed in as \(user.uid)")
            
            // Set a temporary user so updateCurrentUser can fetch the full data
            self.currentUser = User(userId: user.uid, username: user.uid, email: email)
            print("⏳ Fetching full user data from Firestore...")
            
            // Fetch the full user data from Firestore (including friends list)
            await updateCurrentUser()
            
            print("✅ Full user data loaded. Friends count: \(self.currentUser?.friends.count ?? 0)")
            
            self.isLoading = false
            self.isLoggedIn = true
        } catch {
            // Provide user-friendly error messages
            let errorCode = (error as NSError).code
            
            switch errorCode {
            case 17011: // User not found
                self.errorMessage = "This account does not exist. Please check your email or register."
            case 17009: // Wrong password
                self.errorMessage = "Incorrect password. Please try again."
            case 17008: // Invalid email
                self.errorMessage = "Invalid email format. Please check and try again."
            case 17020: // Network error
                self.errorMessage = "Network error. Please check your connection."
            default:
                self.errorMessage = "Login failed. Please try again."
            }
            
            print("❌ Login error: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
    
    func register(email: String, password: String, username: String) async {
        
        // 1. Set loading state
            self.isLoading = true
            self.errorMessage = nil
            
            do {
                // 2. Use the 'await' version of createUser
                let authResult = try await auth.createUser(withEmail: email, password: password)
                print("User registered: \(authResult.user.uid)")

                let user = authResult.user
                let newUser = User(userId: user.uid, username: username, email: email, password: password)
                
                // 3. Use the 'await' version of setData
                try await Firebase.db.collection("users").document(newUser.userId).setData(from: newUser)
                print("User profile saved in Firestore")

                // 4. Update state (we are already on the main thread thanks to @MainActor)
                self.currentUser = newUser
                self.isLoggedIn = true
                self.isLoading = false
                
            } catch {
                // 5. Handle any errors from auth or firestore
                print("Error registering: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
    }

    func signOut() {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func updateCurrentUser() async {
        let db = Firestore.firestore()
        guard let userId = self.currentUser?.userId else { return }
        let userRef = db.collection("users").document(userId)
        
        do {
            let document = try await userRef.getDocument()
            
            // Decode the entire User object from Firestore
            self.currentUser = try document.data(as: User.self)
        } catch {
            print("Can't find user: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deleteAccount() async {
        guard let user = auth.currentUser,
              let currentUserId = self.currentUser?.userId else {
            self.errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        
        do {
            let db = Firestore.firestore()
            
            // 1. Delete all user's posts
            let postsSnapshot = try await db.collection("posts")
                .whereField("userID", isEqualTo: currentUserId)
                .getDocuments()
            
            for document in postsSnapshot.documents {
                try await document.reference.delete()
            }
            print("✅ Deleted all user posts")
            
            // 2. Remove user from all friends lists
            let usersSnapshot = try await db.collection("users").getDocuments()
            
            for document in usersSnapshot.documents {
                let data = document.data()
                var needsUpdate = false
                var updates: [String: Any] = [:]
                
                // Remove from friends arrays
                if var friends = data["friends"] as? [String],
                   let index = friends.firstIndex(of: currentUserId) {
                    friends.remove(at: index)
                    updates["friends"] = friends
                    needsUpdate = true
                }
                
                // Remove from sentFriendRequests
                if var sentRequests = data["sentFriendRequests"] as? [String],
                   let index = sentRequests.firstIndex(of: currentUserId) {
                    sentRequests.remove(at: index)
                    updates["sentFriendRequests"] = sentRequests
                    needsUpdate = true
                }
                
                // Remove from receivedFriendRequests
                if var receivedRequests = data["receivedFriendRequests"] as? [String],
                   let index = receivedRequests.firstIndex(of: currentUserId) {
                    receivedRequests.remove(at: index)
                    updates["receivedFriendRequests"] = receivedRequests
                    needsUpdate = true
                }
                
                if needsUpdate {
                    try await document.reference.updateData(updates)
                }
            }
            print("✅ Removed user from all friends lists")
            
            // 3. Delete user document from Firestore
            try await db.collection("users").document(currentUserId).delete()
            print("✅ Deleted user document")
            
            // 4. Delete user from Firebase Auth
            try await user.delete()
            print("✅ Deleted user from Firebase Auth")
            
            // 5. Clear local state
            self.currentUser = nil
            self.isLoggedIn = false
            self.isLoading = false
            
            print("✅ Account deleted successfully")
            
        } catch {
            print("❌ Error deleting account: \(error.localizedDescription)")
            self.errorMessage = "Failed to delete account: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
