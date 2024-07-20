//
//  AuthViewModel.swift
//  Hit Send
//
//  Created by Abdul Moiz on 20/07/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task { await fetchUser() }
    }
    
    func signIn(withEmail email: String, password: String, completion: @escaping (Error?) -> Void) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            completion(nil)
        } catch {
            completion(error)
            print("DEBUG: Failed to log user in with error \(error.localizedDescription)")
        }
    }
    
//    func createUser(withEmail email: String, password: String, fullname: String) async throws {
//        do {
//            let result = try await Auth.auth().createUser(withEmail: email, password: password)
//            self.userSession = result.user
//            let user = User(id: result.user.uid, fullname: fullname, email: email)
//            let encodedUser = try Firestore.Encoder().encode(user)
//            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
//            await fetchUser()
//            completion(nil)
//        } catch {
//            completion(error)
//            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
//        }
//    }
    
    func createUser(withEmail email: String, password: String, fullname: String, completion: @escaping (Error?) -> Void) async throws {
        do {
            // Create the user with Firebase Authentication
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Create a user object to store in Firestore
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            
            // Encode the user object into Firestore format
            let encodedUser = try Firestore.Encoder().encode(user)
            
            // Save the user data to Firestore
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            
            // Fetch the user details (assuming fetchUser is defined elsewhere)
            await fetchUser()
            
            // Call the completion handler with no error
            completion(nil)
        } catch {
            // Call the completion handler with the error
            completion(error)
            
            // Print the error for debugging purposes
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        print("Delete account...")
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        // print("DEBUG: Current user is \(self.currentUser)")
    }
    
    func sendPasswordResetEmail(for email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
}
