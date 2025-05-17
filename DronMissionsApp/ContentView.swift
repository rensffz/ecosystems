import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Я", systemImage: "person.circle")
                }
            MissionsView()
                .tabItem {
                    Label("Миссии", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
}
