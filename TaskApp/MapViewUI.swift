import SwiftUI
import MapKit

struct MapViewUI: UIViewRepresentable {
    
    @State var latitude: Double
    @State var longitude: Double
    
    func makeUIView(context: Context) -> MKMapView {
         MKMapView(frame: .zero)
    }
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)), animated: true)
    }
}
