import SwiftUI
import FirebaseAuth
import Firebase

struct ContentView: View {
    @State private var index = 0
    @State private var isLoggedIn = false
    @State private var verificationID: String?
    @State private var showVerificationPage = false
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var isVerified = false
    @State private var isUserSelected = false
    @State private var selectedUser: Profile?
    
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoggedIn {
                    LoggedInView()
                } else {
                    if index == 0 {
                        Login(index: $index, isLoggedIn: $isLoggedIn)
                    } else {
                        SignUp(index: $index, isLoggedIn: $isLoggedIn, showVerificationPage: $showVerificationPage)
                    }
                }
                Spacer()
            }
            .navigationBarHidden(true)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .preferredColorScheme(.dark)
        }
    }
    
    
    
    struct Login: View {
        @State private var email = ""
        @State private var password = ""
        @Binding var index: Int
        @Binding var isLoggedIn: Bool
        @State private var showForgotPasswordView = false
        
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
                    // Hata bildirimi için bir alert göster
                    // Örneğin:
                    self.showAlert(message: "Giriş yapma hatası: \(error.localizedDescription)")
                } else {
                    print("Giriş başarılı")
                    self.isLoggedIn = true // Giriş başarılı olduğunda isLoggedIn durumunu true olarak ayarla
                }
            }
        }
        
        // Hata bildirimi için bir fonksiyon
        private func showAlert(message: String) {
            let alert = UIAlertController(title: "E-posta veya şifre hatalı", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    struct SignUp: View {
        @State private var email = ""
        @State private var password = ""
        @State private var rePassword = ""
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
        @State private var verificationID: String?
        @State private var isVerified = false
        @Binding var showVerificationPage: Bool
        
        var body: some View {
            if isVerified {
                LoggedInView() // Burada anasayfaya yönlendirme yapılacak widget
            } else if showVerificationPage {
                VerificationPage(phoneNumber: $phoneNumber, verificationCode: $verificationCode, showVerificationPage: $showVerificationPage, isVerified: $isVerified, verificationID: $verificationID)
            } else {
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
                                    .keyboardType(.phonePad)
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
                    
                    Button(action: {
                        self.showVerificationPage = true // "İLERLE" butonuna tıklandığında showVerificationPage'i true yap
                    }) {
                        Text("İLERLE")
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
        }
    }
    struct VerificationPage: View {
        @Binding var phoneNumber: String
        @Binding var verificationCode: String
        @Binding var showVerificationPage: Bool
        @Binding var isVerified: Bool
        @Binding var verificationID: String?
        @State private var signUpError: String? = nil
        @State private var useEmailVerification = false
        var body: some View {
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Text("Doğrulama")
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
                            Image(systemName: "phone.fill")
                                .foregroundColor(.white)
                            TextField("Telefon Numarası", text:$phoneNumber)
                                .keyboardType(.phonePad)
                        }
                        Divider().background(Color.white.opacity(0.5))
                    }
                    .padding(.horizontal)
                    .padding(.top, 40)
                    
                    VStack {
                        HStack(spacing: 15) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white)
                            SecureField("Doğrulama Kodu", text:$verificationCode)
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
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .shadow(color: Color.black.opacity(0.3), radius: 5, x:0, y: -5)
                .padding(.horizontal, 20)
                
                Button(action: signUp) {
                    Text("KOD GÖNDER")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .padding(.horizontal, 50)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                        .shadow(color: Color.white.opacity(0.1), radius:5, x: 0, y: 5)
                }
                .offset(y: 25)
                
                Button(action: {
                    // Telefon doğrulama kodunu doğrulayın
                    Auth.auth().signIn(with: PhoneAuthProvider.provider().credential(withVerificationID: verificationID ?? "", verificationCode: verificationCode)) { (result, error) in
                        if let error = error {
                            signUpError = "Doğrulama başarısız: \(error.localizedDescription)"
                        } else {
                            // Doğrulama başarılı, kullanıcıyı kayıt işlemi için uygun yere yönlendirin
                            // Örneğin, bir başka görünüme (sayfaya) geçebilirsiniz veya kayıt işlemini tamamlayabilirsiniz
                            // Örnek:
                            isVerified = true // Kullanıcı doğrulandı olarak işaretlenir
                            showVerificationPage = false // Doğrulama sayfasını kapatır
                        }
                    }
                }) {
                    Text("Doğrula")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding()
                        .padding(.vertical)
                        .padding(.horizontal, 50)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                
                
                if let error = signUpError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                
                Button(action: {
                    useEmailVerification = true // E-posta doğrulama kullanılacağını belirt
                }) {
                    Text("E-posta ile Doğrulama")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .padding(.horizontal, 50)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
                        .offset(y: 50)
                }
                
                
                // E-posta doğrulama alanı
                if useEmailVerification {
                    NavigationLink(destination: EmailVerificationPage(isVerified: $isVerified)) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
        }
        
        private func signUp() {
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber,uiDelegate: nil) { verificationID, error in
                if let error = error {
                    signUpError = "Doğrulama kodu gönderme başarısız:\(error.localizedDescription)"
                } else {
                    if let verificationID = verificationID {
                        self.verificationID = verificationID
                    } else {
                        signUpError = "Doğrulama kodu gönderilirken birhata oluştu. Lütfen tekrar deneyin."
                    }
                }
            }
        }
    }
    //    struct EmailVerificationPage: View {
    //        @Binding var isVerified: Bool
    //        @State private var isVerificationEmailSent = false
    //        @State private var errorMessage = ""
    //        
    //        var body: some View {
    //            VStack {
    //                Text("E-posta ile Doğrulama")
    //                    .font(.title)
    //                    .padding()
    //                
    //                if isVerificationEmailSent {
    //                    Text("Doğrulama e-postası gönderildi. Lütfene-postanızı kontrol edin ve doğrulamabağlantısını tıklayın.")
    //                        .padding()
    //                } else {
    //                    Button(action: sendVerificationEmail) {
    //                        Text("Doğrulama E-postası Gönder")
    //                            .padding()
    //                    }
    //                    .alert(isPresented:.constant(!errorMessage.isEmpty)) {
    //                        Alert(title: Text("Hata"), message:Text(errorMessage), dismissButton:.default(Text("Tamam")))
    //                    }
    //                }
    //            }
    //            .onAppear {
    //                Auth.auth().addStateDidChangeListener { _, user in
    //                    if let user = user, user.isEmailVerified {
    //                        isVerified = true
    //                    }
    //                }
    //            }
    //        }
    //        
    //        private func sendVerificationEmail() {
    //            guard let user = Auth.auth().currentUser else {
    //                errorMessage = "Kullanıcı oturumu açılmamış"
    //                return
    //            }
    //            
    //            user.sendEmailVerification { error in
    //                if let error = error {
    //                    errorMessage = "Doğrulama e-postası gönderilirkenbir hata oluştu: \(error.localizedDescription)"
    //                } else {
    //                    isVerificationEmailSent = true
    //                }
    //            }
    //        }
    //    }
    
    
    
    
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
    
}
