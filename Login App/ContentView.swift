import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var index = 0
    @State private var isLoggedIn = false
    
    var body: some View {
            NavigationView {
                ZStack(alignment: .bottom) {
                    if isLoggedIn {
                        LoggedInView()
                    } else {
                        if index == 0 {
                            Login(index: $index, isLoggedIn: $isLoggedIn)
                        } else {
                            NavigationLink(destination: SignUp(index: $index, isLoggedIn: $isLoggedIn), isActive: Binding<Bool>(
                                get: { self.index == 1 },
                                set: { newValue in
                                    self.index = newValue ? 1 : 0
                                }
                            )) {
                                EmptyView()
                            }
                        }
                    }
                }
                .preferredColorScheme(.dark)
            }
        }
}



struct Login: View {
    @State private var email = "" // Kullanıcının e-posta adresini tutacak değişken
    @State private var password = "" // Kullanıcının şifresini tutacak değişken
    @Binding var index: Int // Görünümde bulunan index değerini bağlayacak değişken
    @Binding var isLoggedIn: Bool // Giriş yapılıp yapılmadığını belirleyecek değişken
    @State private var showForgotPasswordView = false // Şifremi Unuttum ekranını gösterip göstermeyeceği değişkeni


    var body: some View{
        VStack{
            Image("logo")// Uygulama logosunu gösterecek görüntü
                .resizable()
                .frame(width: 200, height: 200)
            
            HStack(spacing: 15){
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 1)

            }
            .padding(.horizontal, 30)
            .padding(.top, 50)
            
            VStack{
                HStack(spacing: 15){
                    Image(systemName: "envelope.fill") //Eposta simgesi
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 0.7960784314, blue: 0.01176470588, alpha: 1)))
                    
                    TextField("Email Address", text: self.$email) // Eposta adresini girmek için metin alanı
                }
                Divider().background(Color.white.opacity(0.5))
            }
            .padding(.horizontal)
            .padding(.top, 40)
            
            VStack{
                HStack(spacing: 15){
                    Image(systemName: "eye.slash.fill") //göz işareti
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 0.7960784314, blue: 0.01176470588, alpha: 1)))
                    
                    SecureField("Password", text: self.$password) //şifreyi gizlediğim alan
                }
                Divider().background(Color.white.opacity(0.5))
            }
            .padding(.horizontal)
            .padding(.top, 30)
            
            HStack{
                Spacer() // Sağ tarafta boşluk bırakır, diğer görünümü sağa itmek için
                Button(action: {
                    self.showForgotPasswordView.toggle() // Şifremi Unuttum butonuna tıklandığında ForgotPasswordView sayfasını göstermek için değişkeni toggle ediyorum
                }) {
                    Text("Şifremi Unuttum?") // "Şifremi Unuttum?" metni içeren buton
                        .foregroundColor(Color.white.opacity(0.6)) // Metin rengi
                }
                .sheet(isPresented: $showForgotPasswordView) {
                    ForgotPasswordView() // Şifremi Unuttum butonuna tıklandığında ForgotPasswordView sayfasını göstermek için sheet kullanıyorum
                }
            }
            .padding(.horizontal)
            .padding(.top, 30)

            Button(action: {
                signIn() // Giriş işlemini başlatan buton
            }) {
                Text("Giriş Yap") // "Giriş Yap" metni içeren buton
                    .foregroundColor(.white) // Metin rengi
                    .fontWeight(.bold) // Metin kalınlığı
                    .padding(.vertical) // Dikey dolgu
                    .padding(.horizontal, 50) // Yatay dolgu
                    .background(Color(#colorLiteral(red: 1, green: 0.7960784314, blue: 0.01176470588, alpha: 1))) // Arkaplan rengi
                    .clipShape(Capsule()) // Buton şekli
                    .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5) // Gölge efekti
            }
            .padding(.top, 30)

            HStack{
                Spacer() // Sağ tarafta boşluk bırakır, diğer görünümü sağa itmek için
                Button(action: {
                    withAnimation{
                        self.index = 1 // Kaydolma sayfasına geçişi tetikleyen buton
                    }
                }) {
                    Text("Hesabınız yok mu? Hemen oluşturun") // "Hesabınız yok mu? Hemen oluşturun" metni içeren buton
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 0.7960784314, blue: 0.01176470588, alpha: 1))) // Metin rengi
                        .fontWeight(.bold) // Metin kalınlığı
                }
            }

            .padding(.horizontal)
            .padding(.top, 30)
        }
        .padding(.vertical)
        .padding(.bottom, (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 15)
        .padding()
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).edgesIgnoringSafeArea(.all))
    }
    

    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print("Giriş yapma hatası: \(error.localizedDescription)")
            } else {
                print("Giriş başarılı")
                self.isLoggedIn = true // Giriş başarılı olduğunda isLoggedIn durumunu true olarak ayarla
            }
        }
    }
}


struct SignUp: View {
    @State private var email = ""
    @State private var password = ""
    @State private var rePassword = "" // Ekledim
    @State private var name = ""
    @State private var surname = ""
    @State private var birthDate = Date()
    @State private var gender = ""
    @State private var city = ""
    @State private var district = ""
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var signUpError: String? = nil
    @Binding var index: Int
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Text("Kayıt Ol")
                            .foregroundColor(.white)
                            .font(.title)
                            .fontWeight(.bold)
                        Capsule()
                            .fill(Color.white)
                            .frame(width: 100, height: 5)
                    }
                }
                .padding(.top, 30)
                
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.white)
                        TextField("Email Adresi", text: $email)
                    }
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 40)
                
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "eye.slash.fill")
                            .foregroundColor(.white)
                        SecureField("Şifre", text: $password)
                    }
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white)
                        SecureField("Şifreyi Tekrar Girin", text: $rePassword) // Ekledim
                    }
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 30)
                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                        TextField("Ad", text: $name)
                        TextField("Soyad", text: $surname)
                    }
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 30)

                VStack {
                    HStack(spacing: 15) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.white)
                        TextField("Telefon Numarası", text: $phoneNumber)
                            .keyboardType(.numberPad)
                    }
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                if let error = signUpError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            
            .padding()
            .padding(.bottom, 65)
            .background(Color.black)
            .clipShape(CShape1())
            .contentShape(CShape1())
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: -5)
            .cornerRadius(35)
            .padding(.horizontal, 20)
            
            Button(action: signUp) {
                Text("KAYIT OL")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .padding(.horizontal, 50)
                    .background(Color(#colorLiteral(red: 1, green: 0.7960784314, blue: 0.01176470588, alpha: 1)))
                    .clipShape(Capsule())
                    .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
            }
            .offset(y: 25)
        }
    }

    private func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }

    private func signUp() {
        if password != rePassword {
            signUpError = "Şifreler eşleşmiyor"
            return
        }
        
        if !isPasswordValid(password) {
            signUpError = "Şifre geçersiz: En az 1 büyük harf, 1 küçük harf, 1 rakam ve 1 özel karakter içermeli, en az 8 karakter olmalıdır."
            return
        }
        
        // Şifre geçerli ise telefon numarası doğrulama işlemine devam et
        sendVerificationCode()
    }

    private func sendVerificationCode() {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                signUpError = "Doğrulama kodu gönderme başarısız: \(error.localizedDescription)"
                return
            }
            self.verifyCode(verificationID: verificationID)
        }
    }

    private func verifyCode(verificationID: String?) {
        guard let verificationID = verificationID else {
            signUpError = "Doğrulama kodu gönderilirken bir hata oluştu. Lütfen tekrar deneyin."
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                signUpError = "Doğrulama başarısız: \(error.localizedDescription)"
                return
            }
            signUpError = nil // Doğrulama başarılı, hata mesajını sıfırla
            // Doğrulama başarılıysa, kullanıcıyı ana sayfaya yönlendirme veya başka bir işlem yapma kodunu buraya ekleyebilirsiniz.
            print("Doğrulama başarılı!")
        }
    }
}

struct CShape : Shape {
    func path(in rect: CGRect) -> Path {
        return Path{ path in
            path.move(to: CGPoint(x: rect.width, y: 100))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}

struct CShape1 : Shape {
    func path(in rect: CGRect) -> Path {
        return Path{ path in
            path.move(to: CGPoint(x: 0, y: 100))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
    }
}
