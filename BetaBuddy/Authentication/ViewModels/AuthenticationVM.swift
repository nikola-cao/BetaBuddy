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
    
    func login(email: String, password: String) async {
        isLoading = true
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let user = authResult.user
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.isLoggedIn = true
                print("Signed in as \(user.uid)")
                self.currentUser = User(userId: user.uid, username: user.uid, email: email)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func register(email: String, password: String, username: String) {
        
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error registering: \(error.localizedDescription)")
                print(error)
            } else {
                print("User registered: \(result?.user.uid ?? "")")
            }
            
            guard let user = result?.user else {return}
            
            let newUser = User(userId: user.uid, username: username, email: email, password: password)
            
            do {
            
                
                // The setData(from:) method automatically converts the Codable 'newUser'
                // into a proper Firestore document, including the nested 'myStats' struct.
                try Firebase.db.collection("users").document(newUser.userId).setData(from: newUser) { err in
                    if let err = err {
                        print("Error saving user: \(err)")
                    } else {
                        print("User profile saved in Firestore")
                        
                        // 3. Update currentUser
                        DispatchQueue.main.async {
                            self.currentUser = newUser
                            self.isLoggedIn = true
                            self.isLoading = false
                        }
                    }
                }
            } catch let error {
                print("Error setting Codable data: \(error)")
            }
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
        let userRef = db.collection("users").document(self.currentUser?.userId ?? "")
        
        do {
            let document = try await userRef.getDocument()
            let data = document.data()
            self.currentUser?.username = data?["username"] as? String ?? "username"
            self.currentUser?.email = data?["email"] as? String ?? "email"
            self.currentUser?.friends = data?["friends"] as? [String] ?? []
            self.currentUser?.myPosts = data?["myPosts"] as? [String] ?? []
            
            if let statsDict = data?["myStats"] as? [String: Any] {
                self.currentUser?.myStats = Statistics(
                    numClimbs: statsDict["numClimbs"] as? Int ?? 0,
                    vb: statsDict["vb"] as? Int ?? 0,
                    v0tov1: statsDict["v0tov1"] as? Int ?? 0,
                    v1tov2: statsDict["v1tov2"] as? Int ?? 0,
                    v2tov4: statsDict["v2tov4"] as? Int ?? 0,
                    v4tov6: statsDict["v4tov6"] as? Int ?? 0,
                    v6tov8: statsDict["v6tov8"] as? Int ?? 0,
                    v8tov10: statsDict["v8tov10"] as? Int ?? 0,
                    v10tov12: statsDict["v10tov12"] as? Int ?? 0,
                    v12plus: statsDict["v12plus"] as? Int ?? 0
                )
            }
        } catch {
            print("Can't find user")
        }
    }
}
