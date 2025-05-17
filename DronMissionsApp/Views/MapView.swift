import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition) {
            if #available(iOS 17.0, *) {
                UserAnnotation()
            }
        }
        .mapControls {
            MapUserLocationButton()
        }
        .onReceive(locationManager.$currentLocation) { location in
            if let location = location {
                cameraPosition = .region(MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
