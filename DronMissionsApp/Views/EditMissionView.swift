import SwiftUI

struct EditMissionView: View {
    var mission: Mission
    @ObservedObject var manager: MissionManager

    var body: some View {
        VStack(alignment: .leading) {
            Text("Миссия: \(mission.name)")
                .font(.title)
                .padding()
            List {
                ForEach(mission.points.indices, id: \.self) { i in
                    Text("Точка \(i + 1): " +
                         String(format: "%.4f, %.4f", mission.points[i].latitude, mission.points[i].longitude))
                }
            }
        }
    }
}
