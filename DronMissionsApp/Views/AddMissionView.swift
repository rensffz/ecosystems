import SwiftUI
import MapKit

struct AddMissionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: MissionManager

    // Новое: поддержка редактирования
    var editingMission: Mission? = nil

    @State private var missionName: String = ""
    @State private var points: [CLLocationCoordinate2D] = []
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62),
                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))

    var body: some View {
        VStack {
            GeometryReader { geo in
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        ForEach(points) { coord in
                            Annotation("", coordinate: coord) {
                                Image(systemName: "mappin")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5).sequenced(before: DragGesture(minimumDistance: 0))
                            .onEnded { value in
                                switch value {
                                case .second(true, let drag):
                                    if let drag = drag {
                                        let tapLocation = drag.location
                                        let screenLocation = CGPoint(x: tapLocation.x, y: tapLocation.y)
                                        if let coordinate = proxy.convert(screenLocation, from: .local) {
                                            points.append(coordinate)
                                        }
                                    }
                                default:
                                    break
                                }
                            }
                    )
                    .frame(height: 300)
                }
            }
            .frame(height: 300)

            TextField("Название миссии", text: $missionName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Перетаскиваемый список точек
            EditPointsList(points: $points)

            HStack {
                Button("Отменить") {
                    dismiss()
                }
                .foregroundColor(.red)
                .padding()

                Spacer()

                Button(editingMission != nil ? "Сохранить" : "Добавить") {
                    if let mission = editingMission {
                        manager.updateMission(original: mission, newName: missionName, newPoints: points)
                    } else {
                        manager.addMission(name: missionName, points: points)
                    }
                    dismiss()
                }
                .disabled(missionName.trimmingCharacters(in: .whitespaces).isEmpty || !isNameUnique())
                .padding()
            }
        }
        .padding()
        .onAppear {
            if let mission = editingMission {
                missionName = mission.name
                points = mission.points
            }
        }
    }

    func isNameUnique() -> Bool {
        let trimmed = missionName.trimmingCharacters(in: .whitespaces)
        return !manager.missions.contains {
            $0.name == trimmed && $0.id != editingMission?.id
        }
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String { "\(latitude),\(longitude)" }
}
