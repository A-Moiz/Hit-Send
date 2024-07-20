//
//  Hit_SendApp.swift
//  Hit Send
//
//  Created by Abdul Moiz on 20/07/2024.
//

import SwiftUI
import Firebase

@main
struct Hit_SendApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
