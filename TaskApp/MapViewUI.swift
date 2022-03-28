import SwiftUI
import MapKit

struct MapViewUI: UIViewRepresentable {
    
    @Binding var latitude: Double
    @Binding var longitude: Double
    
    private var task_annotation: MKPointAnnotation
    
    init(latitude: Binding<Double>, longitude: Binding<Double>) {
        self._latitude = latitude
        self._longitude = longitude
        self.task_annotation = MKPointAnnotation()
        task_annotation.title = "Task position"
        task_annotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    func makeUIView(context: Context) -> MKMapView {
         MKMapView(frame: .zero)
    }
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)), animated: true)
        
        if view.annotations.count > 0 {
            let annotations = view.annotations
            view.removeAnnotations(annotations)
        }
        
        task_annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        view.addAnnotation(task_annotation)
    }
}
