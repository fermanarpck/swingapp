//
//  EmailVerificationPage.swift
//  Login App
//
//  Created by Ferman Ali Arpacık on 25.04.2024.
//  Copyright © 2024 Balaji. All rights reserved.
//

import SwiftUI
import FirebaseAuth


struct EmailVerificationPage: View {
    @Binding var isVerified: Bool
    @State private var isVerificationEmailSent = false
    @State private var errorMessage = ""
    @State private var verificationCode = ""
    @State private var email = ""
    
    var body: some View {
        VStack {
            Text("E-posta ile Doğrulama")
                .font(.title)
                .padding()
            
            TextField("E-posta Adresi", text: $email)
                .padding()
            
            if isVerificationEmailSent {
                TextField("Doğrulama Kodu", text: $verificationCode)
                    .padding()
                
                Button(action: verifyCode) {
                    Text("Doğrula")
                        .padding()
                }
                .alert(isPresented: .constant(!errorMessage.isEmpty)) {
                    Alert(title: Text("Hata"), message: Text(errorMessage), dismissButton: .default(Text("Tamam")))
                }
            } else {
                Button(action: sendVerificationEmail) {
                    Text("Doğrulama E-postası Gönder")
                        .padding()
                }
                .alert(isPresented: .constant(!errorMessage.isEmpty)) {
                    Alert(title: Text("Hata"), message: Text(errorMessage), dismissButton: .default(Text("Tamam")))
                }
            }
        }
        .onAppear {
            Auth.auth().addStateDidChangeListener { _, user in
                if let user = user, user.isEmailVerified {
                    isVerified = true
                }
            }
        }
    }
    
    private func sendVerificationEmail() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Kullanıcı oturumu açılmamış"
            return
        }
        
        user.sendEmailVerification { error in
            if let error = error {
                errorMessage = "Doğrulama e-postası gönderilirken bir hata oluştu: \(error.localizedDescription)"
            } else {
                isVerificationEmailSent = true
            }
        }
    }
    
    private func verifyCode() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Kullanıcı oturumu açılmamış"
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: verificationCode)
        
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                errorMessage = "Doğrulama başarısız: \(error.localizedDescription)"
            } else {
                isVerified = true
            }
        }
    }
}
