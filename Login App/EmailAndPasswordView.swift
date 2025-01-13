
import SwiftUI

struct EmailAndPasswordView: View {
    @Binding var email: String
    @Binding var password: String
    @State private var rePassword = "" // Şifrenin tekrarını tutacak değişken
    @State private var signUpError: String? = nil // Kayıt olma sırasında oluşabilecek hata mesajını tutacak değişken
    
    var body: some View {
        VStack {
            // E-posta ve şifre girişi view'ı
            // ...
        }
    }
}
