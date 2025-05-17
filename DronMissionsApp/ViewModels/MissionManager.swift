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
    
    func updateMission(original: Mission, newName: String, newPoints: [CLLocationCoordinate2D]) {
        if let index = missions.firstIndex(where: { $0.id == original.id }) {
            missions[index] = Mission(id: original.id, name: newName, points: newPoints)
        }
    }

}
