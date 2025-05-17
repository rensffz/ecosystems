import SwiftUI

struct MissionsView: View {
    @StateObject var missionManager = MissionManager()
    @State private var showingAddMission = false

    var body: some View {
        NavigationView {
            List {
                ForEach(missionManager.missions) { mission in
                    NavigationLink(destination: MissionDetailView(manager: missionManager, mission: mission)) {
                        Text(mission.name)
                    }
                }
                .onDelete { indexSet in
                    missionManager.missions.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Мои миссии")
            .toolbar {
                Button(action: { showingAddMission.toggle() }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddMission) {
                AddMissionView(manager: missionManager)
            }
        }
    }
}

