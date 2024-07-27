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
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
            completion(nil)
        } catch {
            completion(error)
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
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
    func sendPasswordResetEmail(for email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    //    func updateUserDetails(newEmail: String, newFullName: String, completion: @escaping (Error?) -> Void) async throws {
    //        guard let uid = Auth.auth().currentUser?.uid else { return }
    //
    //        do {
    //            let userRef = Firestore.firestore().collection("users").document(uid)
    //            try await userRef.updateData([
    //                "email": newEmail,
    //                "fullname": newFullName
    //            ])
    //            await fetchUser()
    //            completion(nil)
    //        } catch {
    //            completion(error)
    //            print("DEBUG: Failed to update user profile with error \(error.localizedDescription)")
    //        }
    //    }
    
    func reauthenticateUser(password: String, completion: @escaping (Error?) -> Void) async throws {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            completion(NSError(domain: "No user signed in", code: 401, userInfo: nil))
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        do {
            try await user.reauthenticate(with: credential)
            completion(nil)
        } catch {
            completion(error)
            print("DEBUG: Failed to reauthenticate user with error \(error.localizedDescription)")
        }
    }
    
    func sendEmailVerification(forEmail email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: email) { error in
            completion(error)
        }
    }
    
    //    func updateUserDetails(newEmail: String, password: String, newFullName: String, completion: @escaping (Error?) -> Void) async throws {
    //        guard let currentUser = Auth.auth().currentUser else {
    //            completion(NSError(domain: "No user signed in", code: 401, userInfo: nil))
    //            return
    //        }
    //
    //        do {
    //            try await reauthenticateUser(password: password) { error in
    //                if let error = error {
    //                    completion(error)
    //                    return
    //                }
    //            }
    //
    //            sendEmailVerification(forEmail: newEmail) { error in
    //                if let error = error {
    //                    completion(error)
    //                    return
    //                }
    //            }
    //
    //            try await currentUser.updateEmail(to: newEmail)
    //
    //            let uid = currentUser.uid
    //            let userRef = Firestore.firestore().collection("users").document(uid)
    //            try await userRef.updateData([
    //                "email": newEmail,
    //                "fullname": newFullName
    //            ])
    //
    //            await fetchUser()
    //            completion(nil)
    //        } catch {
    //            completion(error)
    //            print("DEBUG: Failed to update user profile with error \(error.localizedDescription)")
    //        }
    //    }
    
    func updateUserDetails(newEmail: String, newFullName: String, password: String, completion: @escaping (Error?) -> Void) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            completion(NSError(domain: "No user signed in", code: 401, userInfo: nil))
            return
        }
        
        do {
            // Reauthenticate the user
            try await reauthenticateUser(password: password) { error in
                if let error = error {
                    completion(error)
                    return
                }
            }
            
            // Send email verification to the new email address
            sendEmailVerification(forEmail: newEmail) { error in
                if let error = error {
                    completion(error)
                    return
                }
                
                Task {
                    // Wait for email verification (this is simplified for example purposes)
                    while !currentUser.isEmailVerified {
                        try await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 1 second
                        try await currentUser.reload()
                    }
                    
                    let uid = currentUser.uid
                    let userRef = Firestore.firestore().collection("users").document(uid)
                    do {
                        try await userRef.updateData([
                            "email": newEmail,
                            "fullname": newFullName
                        ])
                        await self.fetchUser()
                        completion(nil)
                    } catch {
                        completion(error)
                        print("DEBUG: Failed to update user profile in Firestore with error \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            completion(error)
            print("DEBUG: Failed to update user email with error \(error.localizedDescription)")
        }
    }
}
