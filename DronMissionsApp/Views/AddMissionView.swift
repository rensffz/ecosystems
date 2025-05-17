import SwiftUI
import MapKit

struct AddMissionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: MissionManager

    var editingMission: Mission? = nil

    @State private var missionName: String = ""
    @State private var points: [CLLocationCoordinate2D] = []
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62),
                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))

    private var trimmedName: String {
        missionName.trimmingCharacters(in: .whitespaces)
    }

    private var isNameUnique: Bool {
        !manager.missions.contains {
            $0.name.lowercased() == trimmedName.lowercased() && $0.id != editingMission?.id
        }
    }

    private var isAddDisabled: Bool {
        trimmedName.isEmpty || !isNameUnique || points.isEmpty
    }

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

            VStack(alignment: .leading, spacing: 4) {
                TextField("Название миссии", text: $missionName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !isNameUnique && !trimmedName.isEmpty {
                    Text("Это имя уже занято")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading) {
                EditPointsList(points: $points)

                if points.isEmpty {
                    Text("Добавьте хотя бы одну точку на карту")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading)
                }
            }

            HStack {
                Button("Отменить") {
                    dismiss()
                }
                .foregroundColor(.red)
                .padding()

                Spacer()

                Button(editingMission != nil ? "Сохранить" : "Добавить") {
                    if let mission = editingMission {
                        manager.updateMission(original: mission, newName: trimmedName, newPoints: points)
                    } else {
                        manager.addMission(name: trimmedName, points: points)
                    }
                    dismiss()
                }
                .disabled(isAddDisabled)
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
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String { "\(latitude),\(longitude)" }
}
