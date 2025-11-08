//
//  BetaBuddyApp.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/3/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      if let app = FirebaseApp.app() {
          print("Firebase configured with name: \(app.name)")
      } else {
          print("Firebase configuration failed")
      }
    return true
  }
}

@main
struct BetaBuddyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var authVM: AuthenticationVM
    
    init() {
        
        FirebaseApp.configure()
        print("Firebase configured successfully in App init")
        authVM = AuthenticationVM()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RegisterUserView()
                    .environment(authVM)
            }
        }
    }
}
