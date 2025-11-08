//
//  Temp.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/8/25.
//

import SwiftUI

struct FeedView: View {
    @Environment(AuthenticationVM.self) var authVM
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            
            if let user = authVM.currentUser {
                Text("Logged in to \(user.username)")
            } else {
                Text("Couldn't find current user")
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedView()
            .environment(AuthenticationVM())
    }
}
