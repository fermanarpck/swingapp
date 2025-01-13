import SwiftUI
import FirebaseFirestoreInternal
import UIKit
import FirebaseAuth



struct LoggedInView: View {
    @State private var isLoggedIn = false
    @State private var selectedTabIndex = 0
    var body: some View {
        if #available(iOS 14.0, *) {
            NavigationView {
                VStack {
                    // Ana sayfa içeriği
                    switch selectedTabIndex {
                    case 0: HomeView()
                    case 1: MatchView()
                    case 2: if #available(iOS 15.0, *) {
                        MessageView()
                    } else {
                        // Fallback on earlier versions
                    }
                    case 3: AccountView()
                    default: EmptyView()
                    }
                    
                    Spacer()
                    
                    // Navbar oluşturulacak
                    CustomNavbar(selectedIndex: $selectedTabIndex)
                        .padding()
                        .background(Color.white)
                        .shadow(radius: 1)
                }
            }
        } else {
            // Fallback on earlier versions
        }
        }
}
struct CustomNavbar: View {
    @Binding var selectedIndex: Int
    
    let tabs = ["Ana Sayfa", "Eşleşme", "Mesaj", "Hesabım"]
    let tabIcons = ["house", "star", "message", "person"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices) { index in
                Button(action: {
                    selectedIndex = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcons[index])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(selectedIndex == index ? .blue : .gray)
                        
                        Text(tabs[index])
                            .font(.caption)
                            .foregroundColor(selectedIndex == index ? .blue : .gray)
                    }
                    .padding(8)
                }
                .frame(maxWidth: .infinity)
                .background(selectedIndex == index ? Color.gray.opacity(0.1) : Color.clear)
            }
        }
    }
}
@available(iOS 15.0, *)
struct MessageView: View {
    @State private var messages: [Message] = []
    @State private var newMessage = ""
    @State private var isUserSelected = false
    @State private var selectedUser: Profile?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(messages) { message in
                                    MessageBubble(message: message)
                                }
                            }
                            .padding(.horizontal)
                            .onChange(of: messages.count) { _ in
                                withAnimation {
                                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                                }
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            TextField("Mesajınızı yazın...", text: $newMessage)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($isFocused)
                                .padding(.horizontal)
                            
                            Button(action: sendMessage) {
                                Image(systemName: "paperplane.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .disabled(newMessage.isEmpty)
                            .padding(.trailing)
                        }
                    }
               
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    Text("Mesajlar")
                        .font(.headline)
                }
            }
        }
        .onAppear {
            fetchMessages()
        }
    }
    
    private func sendMessage() {
        guard let currentUser = Auth.auth().currentUser?.displayName else {
            print("Kullanıcı adı alınamadı")
            return
        }
        
        guard let selectedUser = selectedUser else {
            print("Gönderilecek kullanıcı seçilmedi")
            return
        }
        
        let message = Message(id: UUID().uuidString, sender: currentUser, receiver: selectedUser.name, content: newMessage, timestamp: Date())
        messages.append(message)
        newMessage = ""
        isFocused = false
        
        saveMessageToFirestore(message)
    }

    
    private func fetchMessages() {
        let db = Firestore.firestore()
        db.collection("messages").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Belgeler alınamadı")
                return
            }
            
            self.messages = documents.compactMap { document -> Message? in
                guard let sender = document.get("sender") as? String,
                      let receiver = document.get("receiver") as? String,
                      let content = document.get("content") as? String,
                      let timestamp = document.get("timestamp") as? Date else {
                    return nil
                }
                
                return Message(id: document.documentID, sender: sender, receiver: receiver, content: content, timestamp: timestamp)
            }
        }
    }
    
    private func saveMessageToFirestore(_ message: Message) {
        let db = Firestore.firestore()
        db.collection("messages").addDocument(data: [
            "sender": message.sender,
            "receiver": message.receiver,
            "content": message.content,
            "timestamp": message.timestamp
        ]) { error in
            if let error = error {
                print("Mesaj gönderilirken bir hata oluştu: \(error.localizedDescription)")
            } else {
                print("Mesaj başarıyla gönderildi")
            }
        }
    }
}
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.sender == Auth.auth().currentUser?.displayName {
                Spacer()
                Text(message.content)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
            } else {
                Text(message.sender)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(message.content)
                    .padding(12)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16)
                Spacer()
            }
        }
    }
}

struct Message: Identifiable {
    let id: String
    let sender: String
    let receiver: String
    let content: String
    let timestamp: Date
}


struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            MessageView()
        } else {
            // Fallback on earlier versions
        }
    }
}

struct HomeView: View {
    var body: some View {
        Text("Home View")
    }
}

struct MatchView: View {
    // Profil verileri için durum değişkeni
    @State private var profiles: [Profile] = []
    // Şu anki profil indeksi
    @State private var currentIndex = 0
    
    var body: some View {
        // Arka plan
        ZStack {
            // iOS 14 ve sonrası için gradyan arka plan
            if #available(iOS 14.0, *) {
                LinearGradient(gradient: Gradient(colors: [Color("PrimaryColor"), Color("SecondaryColor")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            } else {
                // Önceki sürümler için yedek
                // Fallback on earlier versions
            }
            
            // Ana içerik yığını
            VStack {
                // Üst kısmı doldurmak için boşluk
                Spacer()
                
                // Profil kartlarının bulunduğu yığın
                ZStack {
                    ForEach(profiles.indices, id: \.self) { index in
                        // Her bir profil kartı
                        ProfileCardView(profile: profiles[index])
                            // Profil kartlarının konumunu ayarla
                            .offset(x: CGFloat(index - currentIndex) * UIScreen.main.bounds.width)
                            // Profil kartlarının döndürülme efekti
                            .rotationEffect(.degrees(Double(index - currentIndex) * 10))
                            // Profil kartlarına sürükleme jestini ekle
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        // Sürükleme sırasında hareketi takip et
                                        withAnimation(.default) {
                                            let translation = value.translation.width
                                            // Sürükleme yönüne göre indeksi güncelle
                                            if translation > 0 && currentIndex < profiles.count - 1 {
                                                currentIndex += 1
                                            } else if translation < 0 && currentIndex > 0 {
                                                currentIndex -= 1
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        // Sürükleme işlemi tamamlandığında işlemleri gerçekleştir
                                        // Eşleşme veya beğenme işlemlerini burada gerçekleştirin
                                    }
                            )
                    }
                }
            

                    
                    
                    Spacer()
                    
                    HStack(spacing: 30) {
                        Button(action: dislikeProfile) {
                            Image(systemName: "xmark")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color("DislikeColor"))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Button(action: likeProfile) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color("LikeColor"))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Button(action: sendMessage) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color("MessageColor"))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .onAppear {
                fetchProfiles()
            }
        }
        
        private func fetchProfiles() {
            // Profilleri Firestore veya başka bir veri kaynağından alın
            profiles = dummyProfiles
        }
        
    private func dislikeProfile() {
            // Profili beğenmeme işlemini gerçekleştirin
            print("Profil beğenilmedi")
        }
        
        private func likeProfile() {
            
            // Profili beğenme işlemini gerçekleştirin
            print("Profil beğenildi")
        }
        
        private func sendMessage() {
            // Mesajlaşma ekranına geçin
            _ = profiles[currentIndex]
            if #available(iOS 15.0, *) {
                _ = MessageView()
            } else {
                // Fallback on earlier versions
            }
            // Buraya navigationLink veya present kodunu ekleyin
        }
    }
let dummyProfiles: [Profile] = [
    Profile(name: "Samet", age: 23, location: "İstanbul", bio: "Gemici!", interests: ["kitap okumak", "Mobile legends"], imageURL: "samet_image"),
    Profile(name: "Bob", age: 28, location: "Ankara", bio: "I love hiking!", interests: ["hiking", "photography"], imageURL: "bob_image"),
    Profile(name: "Carol", age: 30, location: "İzmir", bio: "Coffee lover", interests: ["coffee", "movies"], imageURL: "carol_image"),
    Profile(name: "Emre", age: 26, location: "Antalya", bio: "Küresel sermaye yöneticisi", interests: ["sadece yemek yemek"], imageURL: "emre_image")
]

struct ProfileCardView: View {
        let profile: Profile
        
        var body: some View {
            VStack {
                Image(profile.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: UIScreen.main.bounds.height * 0.6)
                    .clipped()
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(profile.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(profile.age) yaşında, \(profile.location)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(profile.bio)
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                    
                    HStack {
                        ForEach(profile.interests, id: \.self) { interest in
                            Text(interest)
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color("InterestColor"))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .bottom, endPoint: .top)
                )
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height * 0.8)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
}

struct Profile: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let location: String
    let bio: String
    let interests: [String]
    let imageURL: String
}
extension Color {
        static let primaryColor = Color("PrimaryColor")
        static let secondaryColor = Color("SecondaryColor")
        static let dislikeColor = Color("DislikeColor")
        static let likeColor = Color("LikeColor")
        static let messageColor = Color("MessageColor")
        static let interestColor = Color("InterestColor")
    }


struct AccountView: View {
    @State private var isLoggedIn = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Hesabım")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding(.bottom, 30)
                
                // Ana ekranda NavigationLink ile ProfileViewController'a geçiş yapmak için:
                NavigationLink(destination: ProfileView()) {
                    AccountMenuItemView(iconName: "person.circle", title: "Profilim")
                }

            
                NavigationLink(destination: PrivacyView()) {
                    AccountMenuItemView(iconName: "lock.circle", title: "Gizlilik ve Güvenlik")
                }
                
                NavigationLink(destination: SettingsView()) {
                    AccountMenuItemView(iconName: "gearshape.fill", title: "Ayarlar")
                }
                
                NavigationLink(destination: MatchHistoryView()) {
                    AccountMenuItemView(iconName: "clock.fill", title: "Eşleşme Geçmişi")
                }
                
                NavigationLink(destination: BlockedUsersView()) {
                    AccountMenuItemView(iconName: "person.2.fill", title: "Engellenen Kullanıcılar")
                }
                
                NavigationLink(destination: HelpView()) {
                    AccountMenuItemView(iconName: "questionmark.circle.fill", title: "Yardım")
                }
                
                Spacer()

                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        print("Çıkış işlemi başarıyla gerçekleşti")
                        DispatchQueue.main.async {
                            presentationMode.wrappedValue.dismiss()
                            // Tüm bağlantıları kes ve Login.swift sayfasına yönlendir
                            let login = ContentView()
                            let rootView = UIHostingController(rootView: login)
                            UIApplication.shared.windows.first?.rootViewController = rootView
                            UIApplication.shared.windows.first?.makeKeyAndVisible()
                        }
                    } catch let signOutError as NSError {
                        print("Çıkış yapılırken bir hata oluştu: \(signOutError.localizedDescription)")
                    }
                }) {
                    Text("Çıkış Yap")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .background(Color.gray.opacity(0.1))

            }
            .padding()
            .navigationBarTitle("Hesabım", displayMode: .inline)
            .background(Color.white)
            
            Spacer()
        }
        .background(Color.gray.opacity(0.1))
    }
}

struct AccountMenuItemView: View {
    var iconName: String
    var title: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(.black)
            
            Text(title)
                .foregroundColor(.black)
                .font(.headline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseCoreInternal


struct ProfileView: View {
    @State private var user: User?
    @State private var showEditProfile = false
    let storage = Storage.storage()
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)), Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))]), center: .center, startRadius: 0, endRadius: 500)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    ProfilePictureView(imageData: user?.profilePictureData, size: 220)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)), Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 5
                                )
                        )
                        .shadow(color: Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)), radius: 20, x: 0, y: 10)
                        .padding(.top, 32)
                    
                    Button(action: {
                        showEditProfile = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)), Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                }
                
                Text("\(user?.firstName ?? "") \(user?.lastName ?? "")")
                    .font(.custom("Avenir Next", size: 40))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 24)
                
                Text("\(user?.age ?? 0) yaşında")
                    .font(.custom("Avenir Next", size: 24))
                    .foregroundColor(.white)
                    .padding(.bottom, 32)
                
                Divider()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white, Color.white.opacity(0.3)]), startPoint: .leading, endPoint: .trailing)
                    )
                    .padding(.horizontal, 80)
                    .padding(.bottom, 32)
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    UserDetailView(title: "İlgi Alanları", value: user?.interests)
                        .padding(.horizontal)
                    UserDetailView(title: "Burç", value: user?.zodiacSign)
                        .padding(.horizontal)
                    UserDetailView(title: "Yetenekler", value: user?.skills)
                        .padding(.horizontal)
                    UserDetailView(title: "Yaşadığı Yer", value: user?.location)
                        .padding(.horizontal)
                    UserDetailView(title: "Okuduğu Okul", value: user?.school)
                        .padding(.horizontal)
                    UserDetailView(title: "Meslek", value: user?.occupation)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            fetchUserData()
        }
        .sheet(isPresented: $showEditProfile) {
            if let user = user {
                EditProfileView(user: $user)
            }
        }
    }

    // Diğer fonksiyonlar...
}
    
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı kimliği alınamadı.")
            return
        }
        //verileri çekmemizi sağlayan kod
        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
            } else if let snapshot = snapshot, let data = snapshot.data() {
                var user = User(dictionary: data)
                user = user // self yerine doğrudan özelliğe ata
            }
        }
    }



struct EditProfileView: View {
    @Binding var user: User?
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = 0
    @State private var interests = ""
    @State private var zodiacSign = ""
    @State private var skills = ""
    @State private var location = ""
    @State private var school = ""
    @State private var occupation = ""
    @State private var profilePictureData: Data? = nil
    @State private var showImagePicker = false
    
    let zodiacSigns = ["Koç", "Boğa", "İkizler", "Yengeç", "Aslan", "Başak", "Terazi", "Akrep", "Yay", "Oğlak", "Kova", "Balık"]
    let skillOptions = ["Programlama", "Tasarım", "Yazarlık", "Müzik", "Resim", "Spor"]
    
    var body: some View {
          NavigationView {
                Form {
                    Section(header: Text("Kişisel Bilgiler")) {
                        TextField("İsim", text: $firstName)
                        TextField("Soyisim", text: $lastName)
                        TextField("Yaş", value: $age, formatter: NumberFormatter())
                    }
                    Section(header: Text("Diğer Bilgiler")) {
                        TextField("İlgi Alanları", text: $interests)
                        TextField("Burç", text: $zodiacSign)
                        TextField("Yetenekler", text: $skills)
                        TextField("Yaşadığı Yer", text: $location)
                        TextField("Okuduğu Okul", text: $school)
                        TextField("Meslek", text: $occupation)
                    }
                    Section(header: Text("Profil Resmi")) {
                        Button(action: { showImagePicker = true }) {
                            if let data = profilePictureData, let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Text("Resim Seç")
                            }
                        }
                    }
                }
                .navigationBarTitle("Profili Düzenle", displayMode: .inline)
                .navigationBarItems(trailing: Button(action: saveProfile) {
                    Text("Kaydet")
                })
                .onAppear {
                    loadUserData()
                }
                .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                    ImagePicker(imageData: $profilePictureData)
                   }
            }
        }
    
    func loadUserData() {
        guard let user = user else { return }
        firstName = user.firstName
        lastName = user.lastName
        age = user.age
        interests = user.interests ?? ""
        zodiacSign = user.zodiacSign ?? ""
        skills = user.skills ?? ""
        location = user.location ?? ""
        school = user.school ?? ""
        occupation = user.occupation ?? ""
        profilePictureData = user.profilePictureData
    }
    
    func loadImage() {
        if let data = profilePictureData {
            user?.profilePictureData = data
        }
    }
    
    func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        var userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "age": age,
            "interests": interests,
            "zodiacSign": zodiacSign,
            "skills": skills,
            "location": location,
            "school": school,
            "occupation": occupation
        ]
        
        if let profilePictureData = profilePictureData {
            uploadProfilePicture(userId: userId, data: profilePictureData) { url in
                userData["profilePictureURL"] = url?.absoluteString
                saveUserData(userId: userId, userData: userData)
            }
        } else {
            saveUserData(userId: userId, userData: userData)
        }
    }
    
    func saveUserData(userId: String, userData: [String: Any]) {
        Firestore.firestore().collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
            } else {
                self.user = User(dictionary: userData)
            }
        }
    }
    
    func uploadProfilePicture(userId: String, data: Data, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference().child("profile_pictures/\(userId).jpg")
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        storageRef.putData(data, metadata: uploadMetadata) { (metadata, error) in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Hata: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        completion(url)
                    }
                }
            }
        }
    }
}
struct CustomTextField: View {
    let placeHolder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeHolder, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(keyboardType)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
    }
}

struct User: Codable {
    let uid: String
    let email: String
    var firstName: String
    var lastName: String
    var age: Int
    var profilePictureURL: String?
    var profilePictureData: Data?
    var interests: String?
    var zodiacSign: String?
    var skills: String?
    var location: String?
    var school: String?
    var occupation: String?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case firstName
        case lastName
        case age
        case profilePictureURL
        case profilePictureData
        case interests
        case zodiacSign
        case skills
        case location
        case school
        case occupation
    }
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.age = dictionary["age"] as? Int ?? 0
        self.profilePictureURL = dictionary["profilePictureURL"] as? String
        self.profilePictureData = dictionary["profilePictureData"] as? Data
        self.interests = dictionary["interests"] as? String
        self.zodiacSign = dictionary["zodiacSign"] as? String
        self.skills = dictionary["skills"] as? String
        self.location = dictionary["location"] as? String
        self.school = dictionary["school"] as? String
        self.occupation = dictionary["occupation"] as? String
    }
}

struct UserDetailView: View {
    let title: String
    let value: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Avenir Next", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if let value = value, !value.isEmpty {
                Text(value)
                    .font(.custom("Avenir Next", size: 16))
                    .foregroundColor(Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
            } else {
                Text("Bilgi yok")
                    .font(.custom("Avenir Next", size: 16))
                    .foregroundColor(.gray)
            }
        }
    }
}
struct ProfilePictureView: View {
    let imageData: Data?
    let size: CGFloat
    
    var body: some View {
        ZStack {
            if let imageData = imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(.gray)
            }
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.imageData = editedImage.jpegData(compressionQuality: 0.8)
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.imageData = originalImage.jpegData(compressionQuality: 0.8)
            }
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct ProfileTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct ProfileDatePicker: View {
    var title: String
    @Binding var date: Date

    var body: some View {
        DatePicker(selection: $date, in: ...Date(), displayedComponents: .date) {
            Text(title)
        }
        .padding()
    }
}

struct PrivacyView: View {
    var body: some View {
        Text("Gizlilik ve Güvenlik")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Ayarlar")
    }
}

struct MatchHistoryView: View {
    var body: some View {
        Text("Eşleşme Geçmişi")
    }
}

struct BlockedUsersView: View {
    var body: some View {
        Text("Engellenen Kullanıcılar")
    }
}

struct HelpView: View {
    var body: some View {
        Text("Yardım")
    }
}








