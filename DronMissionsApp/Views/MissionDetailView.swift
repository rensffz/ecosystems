import SwiftUI
import MapKit

struct MissionDetailView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var manager: MissionManager
    var mission: Mission

    @State private var isSimulating = false
    @State private var isPaused = false
    @State private var showingEdit = false

    @State private var currentIndex = 0
    @State private var dronePosition: CLLocationCoordinate2D?
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62),
                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))

    let animationDuration: TimeInterval = 2.0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Заголовок с кнопками
                HStack {
                    Text(mission.name)
                        .font(.title2.bold())

                    Spacer()

                    HStack(spacing: 12) {
                        Button(action: {
                            showingEdit = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.orange)
                                .imageScale(.large)
                        }

                        Button(action: {
                            isSimulating ? stopSimulation() : startSimulation()
                        }) {
                            Image(systemName: isSimulating ? "stop.fill" : "play.fill")
                                .foregroundColor(isSimulating ? .red : .blue)
                                .imageScale(.large)
                        }
                    }
                }
                .padding(.horizontal)

                // Карта
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        ForEach(mission.points) { coord in
                            Annotation("", coordinate: coord) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }

                        if let drone = dronePosition {
                            Annotation("Drone", coordinate: drone) {
                                Image(systemName: "paperplane.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.green)
                                    .shadow(radius: 5)
                            }
                        }

                        if mission.points.count >= 2 {
                            MapPolyline(coordinates: mission.points)
                                .stroke(Color.blue, lineWidth: 3)
                        }
                    }
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .shadow(radius: 4)
                }

                // Точки маршрута
                VStack(alignment: .leading, spacing: 8) {
                    Text("Точки маршрута")
                        .font(.headline)
                        .padding(.bottom, 4)

                    ForEach(Array(mission.points.enumerated()), id: \.offset) { index, point in
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("Точка \(index + 1): \(point.latitude, specifier: "%.6f"), \(point.longitude, specifier: "%.6f")")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            AddMissionView(manager: manager, editingMission: mission)
        }
        .onAppear {
            dronePosition = mission.points.first
        }
    }

    // MARK: - Анимация

    func startSimulation() {
        guard mission.points.count > 1 else { return }

        isSimulating = true
        isPaused = false
        currentIndex = 0
        dronePosition = mission.points[0]
        moveToNextPoint()
    }

    func stopSimulation() {
        isSimulating = false
        isPaused = false
        currentIndex = 0
        dronePosition = mission.points.first
    }

    func moveToNextPoint() {
        guard isSimulating, !isPaused else { return }

        // Завершение
        if currentIndex >= mission.points.count - 1 {
            stopSimulation()
            return
        }

        let nextIndex = currentIndex + 1
        let nextPoint = mission.points[nextIndex]

        withAnimation(.linear(duration: animationDuration)) {
            dronePosition = nextPoint
            cameraPosition = .region(MKCoordinateRegion(
                center: nextPoint,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }

        currentIndex = nextIndex

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            moveToNextPoint()
        }
    }
}
