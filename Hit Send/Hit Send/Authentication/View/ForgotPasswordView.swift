//
//  ForgotPasswordView.swift
//  Hit Send
//
//  Created by Abdul Moiz on 20/07/2024.
//

import SwiftUI
import Firebase

struct ForgotPasswordView: View {
    @State private var email = ""
    @Environment(\.colorScheme) var colourScheme
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var emailMessage = ""
    @State private var showAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("If there is an account with the email address below, you will receive an email with a link to reset your password")
                    .font(.callout)
                    .padding(20)
                
                // form fields
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .textInputAutocapitalization(.none)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Submit button
                Button {
                    Task { await sendPasswordResetEmail() }
                } label: {
                    HStack {
                        Text("Send email")
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
            }
            .navigationTitle("Reset password")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Reset Password"),
                    message: Text("\(emailMessage)"),
                    dismissButton: .default(Text("OK")){
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func sendPasswordResetEmail() async {
        viewModel.sendPasswordResetEmail(for: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    showAlert = true
                    emailMessage = error.localizedDescription
                } else {
                    showAlert = true
                    emailMessage = "Email sent to \(email)"
                }
            }
        }
    }
}

extension ForgotPasswordView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@")  && (email.contains(".com") || email.contains(".co.uk") || email.contains(".ac.uk") || email.contains(".org") || email.contains(".net"))
    }
}

#Preview {
    ForgotPasswordView()
}
