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
    @State private var updateDetails = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(viewModel.currentUser?.fullname ?? "")
                
                Divider()
                
                Button {
                    viewModel.signOut()
                } label: {
                    Text("Sign out")
                }
                
                Divider()
                
                Button {
                    updateDetails.toggle()
                } label: {
                    Text("Update details")
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $updateDetails) {
                UpdateDetailsView()
            }
        }
    }
}

//#Preview {
//    ProfileView()
//}
