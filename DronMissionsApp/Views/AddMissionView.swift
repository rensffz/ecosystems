import SwiftUI
import MapKit

struct AddMissionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: MissionManager

    var editingMission: Mission? = nil

    @State private var missionName: String = ""
    @State private var points: [CLLocationCoordinate2D] = []
    @State private var isAddingPoint = false
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62),
                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    @State private var selectedPointIndex: Int? = nil
    @Namespace private var annotationNamespace

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
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок
                HStack {
                    Text(editingMission != nil ? "Редактировать миссию" : "Новая миссия")
                        .font(.title2.bold())
                    Spacer()
                }
                .padding(.horizontal)

                // Карта
                GeometryReader { geo in
                    MapReader { proxy in
                        ZStack {
                            Map(position: $cameraPosition, interactionModes: isAddingPoint ? [] : [.all]) {
                                ForEach(Array(points.enumerated()), id: \.offset) { index, coord in
                                    Annotation("", coordinate: coord) {
                                        Button(action: {
                                            selectedPointIndex = index
                                            withAnimation {
                                                cameraPosition = .region(MKCoordinateRegion(
                                                    center: coord,
                                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                                ))
                                            }
                                        }) {
                                            Image(systemName: "mappin.circle.fill")
                                                .resizable()
                                                .frame(width: selectedPointIndex == index ? 40 : 24,
                                                       height: selectedPointIndex == index ? 40 : 24)
                                                .foregroundColor(selectedPointIndex == index ? .blue : .red)
                                                .shadow(radius: selectedPointIndex == index ? 6 : 0)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }

                            }
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)
                            
                            if let selectedIndex = selectedPointIndex {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            points.remove(at: selectedIndex)
                                            selectedPointIndex = nil
                                        }) {
                                            Label("Удалить точку", systemImage: "trash")
                                                .padding()
                                                .background(Color.red)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                .shadow(radius: 5)
                                        }
                                        .padding()
                                    }
                                }
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }


                            if isAddingPoint {
                                Color.black.opacity(0.001)
                                    .gesture(
                                        LongPressGesture(minimumDuration: 0.3)
                                            .sequenced(before: DragGesture(minimumDistance: 0))
                                            .onEnded { value in
                                                switch value {
                                                case .second(true, let drag?):
                                                    let tapLocation = drag.location
                                                    if let coord = proxy.convert(tapLocation, from: .local) {
                                                        points.append(coord)
                                                    }
                                                default:
                                                    break
                                                }
                                            }
                                    )
                            }
                        }
                    }
                }
                .frame(height: 300)
                .padding(.horizontal)

                // Кнопка "Добавить точку"
                Button(isAddingPoint ? "Готово" : "Добавить точку") {
                    isAddingPoint.toggle()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(isAddingPoint ? Color.green : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                // Поле названия
                VStack(alignment: .leading, spacing: 6) {
                    Text("Название миссии")
                        .font(.headline)
                    TextField("Введите название", text: $missionName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if !isNameUnique && !trimmedName.isEmpty {
                        Text("Это имя уже занято")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Точки маршрута")
                        .font(.headline)
                        .padding(.bottom, 4)

                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                        Button(action: {
                            selectedPointIndex = index
                            withAnimation {
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: point,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                ))
                            }
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                Text("Точка \(index + 1): \(point.latitude, specifier: "%.6f"), \(point.longitude, specifier: "%.6f")")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal)
                            .background(selectedPointIndex == index ? Color.blue.opacity(0.2) : Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedPointIndex == index ? Color.blue : .clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                }
                .padding(.horizontal)

                // Кнопки управления
                HStack {
                    Button("Отменить") {
                        dismiss()
                    }
                    .foregroundColor(.red)

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
                    .padding(.horizontal)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onAppear {
            if let mission = editingMission {
                missionName = mission.name
                points = mission.points
                selectedPointIndex = nil
            }
        }
    }

}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String { "\(latitude),\(longitude)" }
}
