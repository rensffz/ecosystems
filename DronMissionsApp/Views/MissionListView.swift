import SwiftUI

struct MissionListView: View {
    @ObservedObject var manager: MissionManager
    @State private var showingAddView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(manager.missions) { mission in
                    NavigationLink(destination: MissionDetailView(manager: manager, mission: mission)) {
                        Text(mission.name)
                    }
                }
                .onDelete { indexSet in
                    manager.missions.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Мои миссии")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddMissionView(manager: manager)
            }
        }
    }
}
