import SwiftUI
import MapKit

struct MissionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: MissionManager
    var mission: Mission

    @State private var showingEdit = false

    // Для симуляции
    @State private var isSimulating = false
    @State private var currentPointIndex = 0
    @State private var dronePosition: CLLocationCoordinate2D?
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62),
                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    )
    @State private var simulationTimer: Timer?

    var body: some View {
        VStack {
            Text("Название: \(mission.name)")
                .font(.headline)
                .padding()

            // Карта с положением дрона
            Map(position: $cameraPosition) {
                // Точки миссии
                ForEach(mission.points) { coord in
                    Annotation("", coordinate: coord) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                    }
                }

                // Аннотация дрона, если симуляция запущена
                if let dronePos = dronePosition {
                    Annotation("", coordinate: dronePos) {
                        Image(systemName: "airplane")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                }
            }
            .frame(height: 300)
            .onAppear {
                // Инициализируем камеру на первую точку миссии, если есть
                if let first = mission.points.first {
                    cameraPosition = .region(
                        MKCoordinateRegion(center: first,
                                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    )
                    dronePosition = first
                    currentPointIndex = 0
                }
            }

            List {
                ForEach(mission.points.indices, id: \.self) { i in
                    Text("Точка \(i + 1): \(mission.points[i].latitude), \(mission.points[i].longitude)")
                        .font(.caption)
                }
            }

            Spacer()

            HStack {
                Button(isSimulating ? "Остановить симуляцию" : "Старт симуляции") {
                    if isSimulating {
                        stopSimulation()
                    } else {
                        startSimulation()
                    }
                }
                .padding()
                .disabled(mission.points.isEmpty)

                Spacer()

                Button("Изменить") {
                    showingEdit = true
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddMissionView(manager: manager, editingMission: mission)
        }
        .onDisappear {
            stopSimulation()
        }
    }

    func startSimulation() {
        guard !mission.points.isEmpty else { return }

        isSimulating = true
        currentPointIndex = 0
        dronePosition = mission.points[0]
        cameraPosition = .region(
            MKCoordinateRegion(center: mission.points[0],
                               span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        )

        simulationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            moveToNextPoint()
        }
    }

    func stopSimulation() {
        isSimulating = false
        simulationTimer?.invalidate()
        simulationTimer = nil
    }

    func moveToNextPoint() {
        guard isSimulating else { return }
        let nextIndex = currentPointIndex + 1
        if nextIndex < mission.points.count {
            withAnimation(.linear(duration: 1.5)) {
                dronePosition = mission.points[nextIndex]
                cameraPosition = .region(
                    MKCoordinateRegion(center: mission.points[nextIndex],
                                       span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                )
            }
            currentPointIndex = nextIndex
        } else {
            // Конец маршрута — останавливаем симуляцию
            stopSimulation()
        }
    }
}
