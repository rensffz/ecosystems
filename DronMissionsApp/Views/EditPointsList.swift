import SwiftUI
import CoreLocation

struct EditPointsList: View {
    @Binding var points: [CLLocationCoordinate2D]

    var body: some View {
        List {
            ForEach(points.indices, id: \.self) { i in
                HStack {
                    Text("Точка \(i + 1)")
                    Spacer()
                    Text(String(format: "%.4f, %.4f", points[i].latitude, points[i].longitude))
                }
            }
            .onDelete { indexSet in
                points.remove(atOffsets: indexSet)
            }
            .onMove { from, to in
                points.move(fromOffsets: from, toOffset: to)
            }
        }
        .toolbar {
            EditButton()
        }
    }
}
