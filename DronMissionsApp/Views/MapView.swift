import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))

    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
        }
        .task {
            if let coord = locationManager.currentLocation {
                cameraPosition = .region(MKCoordinateRegion(center: coord,
                                                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
