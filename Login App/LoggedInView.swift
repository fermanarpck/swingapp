import SwiftUI

struct HomeView: View {
    var body: some View {
        Text("Home View")
    }
}

struct MatchView: View {
    var body: some View {
        Text("Match View")
    }
}

struct MessageView: View {
    var body: some View {
        Text("Message View")
    }
}

struct AccountView: View {
    var body: some View {
        Text("Account View")
    }
}

struct LoggedInView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Bugün nasıl hissediyorsun?")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                // Ana sayfa içeriği buraya gelecek
                
                Spacer()
                
                // Navbar oluşturulacak
                HStack {
                    Spacer()
                    NavigationLink(destination: HomeView()) {
                        Text("Ana Sayfa")
                    }
                    Spacer()
                    NavigationLink(destination: MatchView()) {
                        Text("Eşleşme")
                    }
                    Spacer()
                    NavigationLink(destination: MessageView()) {
                        Text("Mesaj")
                    }
                    Spacer()
                    NavigationLink(destination: AccountView()) {
                        Text("Hesabım")
                    }
                    Spacer()
                }
                .padding()
                .background(Color.gray)
            }
        }
    }
}
