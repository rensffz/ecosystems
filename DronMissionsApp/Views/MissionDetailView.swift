import SwiftUI
import MapKit

struct MissionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: MissionManager
    var mission: Mission

    @State private var showingEdit = false

    var body: some View {
        VStack {
            Text("Название: \(mission.name)")
                .font(.headline)
                .padding()

            List {
                ForEach(mission.points.indices, id: \.self) { i in
                    Text("Точка \(i + 1): \(mission.points[i].latitude), \(mission.points[i].longitude)")
                        .font(.caption)
                }
            }

            Spacer()

            Button("Изменить") {
                showingEdit = true
            }
            .padding()
        }
        .sheet(isPresented: $showingEdit) {
            AddMissionView(manager: manager, editingMission: mission)
        }
    }
}
