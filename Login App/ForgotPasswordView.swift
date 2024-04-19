import SwiftUI
import FirebaseAuth // Firebase Authentication kütüphanesini içe aktarır

struct ForgotPasswordView: View { // ForgotPasswordView adında bir SwiftUI görünüm yapısı tanımlar
    @State private var email = "" // E-posta adresini saklayacak değişken
    @State private var showAlert = false // Uyarı gösterme durumunu saklayacak değişken
    @State private var alertMessage = "" // Uyarı mesajını saklayacak değişken
    
    var body: some View {
        VStack {
            TextField("E-posta adresinizi girin", text: $email) // E-posta adresini girmek için metin alanı
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle()) // Metin alanı stili
            
            Button(action: resetPassword) { // Şifre sıfırlama işlemini başlatan buton
                Text("Şifreyi Sıfırla") // Buton metni
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Şifremi Unuttum") // Sayfa başlığını belirler
        .alert(isPresented: $showAlert) { // Uyarı mesajını göstermek için uygun durum kontrolü
            Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam"))) // Uyarı iletişim kutusunu tanımlar
        }
    }
    
    private func resetPassword() { // Şifre sıfırlama işlemini gerçekleştirir
        Auth.auth().sendPasswordReset(withEmail: email) { error in // Firebase Authentication üzerinden şifre sıfırlama e-postası gönderir
            if let error = error { // Hata varsa
                alertMessage = "Şifre sıfırlama e-postası gönderilirken bir hata oluştu: \(error.localizedDescription)" // Hata mesajını ayarlar
            } else { // Hata yoksa
                alertMessage = "Şifre sıfırlama e-postası başarıyla gönderildi. Lütfen e-posta adresinizi kontrol edin." // Başarılı mesajını ayarlar
            }
            showAlert = true // Uyarıyı göster
        }
    }
}
