//
//  UpdateDetailsView.swift
//  Hit Send
//
//  Created by Abdul Moiz on 27/07/2024.
//

import SwiftUI

struct UpdateDetailsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colourScheme
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // form fields
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .textInputAutocapitalization(.none)
                    
                    InputView(text: $fullname, title: "Full Name", placeholder: "Enter your name")
                    
                    InputView(text: $password, title: "Password", placeholder: "Create a password", isSecureField: true)
                    
                    ZStack(alignment: .trailing) {
                        InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm your password", isSecureField: true)
                        
                        if (!password.isEmpty && !confirmPassword.isEmpty) {
                            if password == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(.systemGreen))
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(.systemRed))
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 32)
                
                Button {
                    Task {
                        try await viewModel.updateUserDetails(newEmail: email, newFullName: fullname, password: password) { error in
                            if let error = error {
                                alertMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Send email verification")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.red)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(colourScheme == .dark ? .white : .black)
                .cornerRadius(10)
                .padding(.vertical, 24)
                
                Button {
                    Task {
                        try await viewModel.updateUserDetails(newEmail: email, newFullName: fullname, password: password) { error in
                            if let error = error {
                                alertMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Update")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.red)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(colourScheme == .dark ? .white : .black)
                .cornerRadius(10)
                .padding(.vertical, 24)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                Spacer()
            }
            .navigationTitle("Update Details")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Update details"),
                    message: Text("\(alertMessage)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

extension UpdateDetailsView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return (!email.isEmpty || !fullname.isEmpty || (!password.isEmpty && !confirmPassword.isEmpty)) && email.contains("@")  && (email.contains(".com") || email.contains(".co.uk") || email.contains(".ac.uk") || email.contains(".org") || email.contains(".net")) && password.count > 5 && confirmPassword == password
    }
}

#Preview {
    UpdateDetailsView()
}
