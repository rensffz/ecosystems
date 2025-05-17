import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Карта", systemImage: "map")
                }
            MissionsView()
                .tabItem {
                    Label("Миссии", systemImage: "list.bullet")
                }
        }
    }
}
