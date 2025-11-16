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
            self.errorMessage = error.localizedDescription
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
}
