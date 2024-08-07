//
//  MapView.swift
//  GeoQuiz
//
//  Created by Chris Lucas on 12.12.20.
//

import Foundation
import SwiftUI
import MapKit

struct UIKitMapView: UIViewRepresentable {
    // Input Publishers
    @Binding var isEdit: Bool
    
    // Config Parameters
    var places: [GeoPlace]
    
    // Listeners
    var onPlaceClicked: ((_ place: GeoPlace) -> Void)?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        mapView.pointOfInterestFilter = .excludingAll
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        //guard let places = places else { return }
        
        uiView.removeAnnotations(uiView.annotations)
        var annotations = [MKPointAnnotation]()
        
        for place in places {
            annotations.append(place)
        }
        
        uiView.addAnnotations(annotations)
        uiView.showAnnotations(annotations, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: UIKitMapView
        
        init(_ parent: UIKitMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let onPlaceClicked = parent.onPlaceClicked else { return }
            guard let annotation = view.annotation else { return }
            
            if annotation is GeoPlace {
                onPlaceClicked(annotation as! GeoPlace)
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier = annotation.title
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier!!)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier!)
            } else {
                annotationView?.annotation = annotation
            }
            
            annotationView?.canShowCallout = !parent.isEdit
            
            if annotation is GeoPlace {
                switch (annotation as! GeoPlace).state {
                case .guessing:
                    (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.black
                    break
                case .answered:
                    (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.blue
                    break
                case .correct:
                    (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.green
                    break
                case .incorrect:
                    (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.red
                    break
                }
            }
            
            return annotationView
        }
    }
}
