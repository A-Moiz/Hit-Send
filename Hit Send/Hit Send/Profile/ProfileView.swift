//
//  ProfileView.swift
//  Hit Send
//
//  Created by Abdul Moiz on 20/07/2024.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colourScheme
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        
        Divider()
        
        Button {
            viewModel.signOut()
        } label: {
            Text("Sign out")
        }
    }
}

#Preview {
    ProfileView()
}
