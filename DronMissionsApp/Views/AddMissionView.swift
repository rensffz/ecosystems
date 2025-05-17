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
                        DragGesture(minimumDistance: 0)
                            .onEnded { gesture in
                                let tapLocation = gesture.location
                                let screenLocation = CGPoint(
                                    x: tapLocation.x,
                                    y: tapLocation.y
                                )

                                if let coordinate = proxy.convert(screenLocation, from: .local) {
                                    points.append(coordinate)
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

            EditPointsList(points: $points)

            Button("Добавить") {
                manager.addMission(name: missionName, points: points)
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String { "\(latitude),\(longitude)" }
}
