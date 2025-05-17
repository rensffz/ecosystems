import SwiftUI
import MapKit

struct MissionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: MissionManager
    var mission: Mission

    @State private var showingEdit = false

    // Симуляция
    @State private var isSimulating = false
    @State private var isPaused = false
    @State private var currentIndex = 0
    @State private var dronePosition: CLLocationCoordinate2D?

    // Новое: выделенная точка (индекс)
    @State private var selectedPointIndex: Int? = nil

    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62),
                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    )

    let animationDuration: Double = 1.0

    var body: some View {
        VStack {
            Text("Название: \(mission.name)")
                .font(.headline)
                .padding()

            Map(position: $cameraPosition) {
                ForEach(mission.points.indices, id: \.self) { i in
                    let coord = mission.points[i]
                    Annotation("", coordinate: coord) {
                        // Маркер выделенной точки — крупнее и краснее
                        if selectedPointIndex == i {
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.red)
                                .shadow(radius: 5)
                                .zIndex(1)
                        } else {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .frame(width: 24, height: 24)
                        }
                    }
                }

                if let dronePos = dronePosition {
                    Annotation("", coordinate: dronePos) {
                        Image("icons8-quadcopter-24")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .frame(height: 300)
            .onAppear {
                if let first = mission.points.first {
                    dronePosition = first
                    currentIndex = 0
                    cameraPosition = .region(MKCoordinateRegion(
                        center: first,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    ))
                }
            }

            List {
                ForEach(mission.points.indices, id: \.self) { i in
                    Button {
                        // При нажатии на точку из списка выделяем и центрируем карту
                        selectedPointIndex = i
                        let coord = mission.points[i]
                        withAnimation(.easeInOut(duration: 0.5)) {
                            cameraPosition = .region(MKCoordinateRegion(
                                center: coord,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // приближаем
                            ))
                        }
                    } label: {
                        Text("Точка \(i + 1): \(mission.points[i].latitude), \(mission.points[i].longitude)")
                            .font(.caption)
                            .foregroundColor(selectedPointIndex == i ? .blue : .primary)
                    }
                }
            }

            Spacer()

            HStack(spacing: 16) {
                if isSimulating {
                    if isPaused {
                        Button("Продолжить") {
                            isPaused = false
                            moveToNextPoint()
                        }
                    } else {
                        Button("Пауза") {
                            isPaused = true
                        }
                    }

                    Button("Остановить") {
                        stopSimulation()
                    }
                    .foregroundColor(.red)

                } else {
                    Button("Старт симуляции") {
                        startSimulation()
                    }
                    .disabled(mission.points.count < 2)
                }

                Spacer()

                Button("Изменить") {
                    showingEdit = true
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingEdit) {
            AddMissionView(manager: manager, editingMission: mission)
        }
        .onDisappear {
            stopSimulation()
        }
    }

    // MARK: - Симуляция

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

        // Если мы уже на последней точке, то останавливаем симуляцию
        if currentIndex >= mission.points.count - 1 {
            isSimulating = false
            isPaused = false
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
