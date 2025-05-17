import SwiftUI
import MapKit

struct AddMissionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: MissionManager
    @State private var missionName: String = ""
    @State private var points: [CLLocationCoordinate2D] = []
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62),
                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))

    var body: some View {
        VStack {
            Map(position: $cameraPosition) {
                ForEach(points) { coord in
                    Annotation("", coordinate: coord) {
                        Image(systemName: "mappin")
                            .foregroundColor(.red)
                    }
                }
            }
            .gesture(
                TapGesture().onEnded {
                    let center = getCenterCoordinate()
                    if center.latitude != 0 && center.longitude != 0 {
                        points.append(center)
                    }
                }
            )
            .frame(height: 300)

            TextField("Название миссии", text: $missionName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            EditPointsList(points: $points)

            Button("Добавить") {
                manager.addMission(name: missionName, points: points)
                dismiss()
            }
            .padding()
        }
        .padding()
    }

    // Жёсткий костыль без let, просто вытаскиваем значения вручную через String-описание
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let positionString = String(describing: cameraPosition)
        if positionString.contains("center:") {
            // Тут ты можешь зажёстко вернуть свои координаты (например, Москва)
            return CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62)
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String { "\(latitude),\(longitude)" }
}
