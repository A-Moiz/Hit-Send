//
//  LoginView.swift
//  Hit Send
//
//  Created by Abdul Moiz on 20/07/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @Environment(\.colorScheme) var colourScheme
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // form fields
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .textInputAutocapitalization(.none)
                    
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 32)
                
                // Forgot password button
                NavigationLink {
                    ForgotPasswordView()
                } label: {
                    HStack() {
                        Spacer()
                        
                        Text("Forgot password")
                    }
                }
                .padding(.top, 5)
                .padding(.horizontal, 15)
                .foregroundStyle(.red)
                .font(.system(size: 16))
                
                // sign in button
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password) { error in
                            if let error = error {
                                alertMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Sign in")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.red)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(colourScheme == .dark ? .white : .black)
                .cornerRadius(10)
                .padding(.top, 24)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                Spacer()
                
                // sign up button
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden()
                } label: {
                    VStack(spacing: 15) {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width, height: 1)
                            .foregroundColor(.gray)
                        HStack {
                            Text("Don't have an account?")
                            Text("Sign up")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Welcome back")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Signing in"),
                    message: Text("\(alertMessage)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@")  && (email.contains(".com") || email.contains(".co.uk") || email.contains(".ac.uk") || email.contains(".org") || email.contains(".net")) && !password.isEmpty && password.count > 5
    }
}

#Preview {
    LoginView()
}
