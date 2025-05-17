import Foundation
import CoreLocation

class MissionManager: ObservableObject {
    @Published var missions: [Mission] = [] {
        didSet {
            saveMissions()
        }
    }

    private let saveKey = "SavedMissions"

    init() {
        loadMissions()
    }

    func addMission(name: String, points: [CLLocationCoordinate2D]) {
        let mission = Mission(name: name, points: points)
        missions.append(mission)
    }

    func saveMissions() {
        if let data = try? JSONEncoder().encode(missions) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func loadMissions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Mission].self, from: data) {
            missions = decoded
        }
    }
}
