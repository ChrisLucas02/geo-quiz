//
//  LocationManager.swift
//  GeoQuiz
//
//  Created by Chris Lucas on 13.12.20.
//

import Foundation
import CoreLocation
import Combine
import MapKit

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published private(set) var location: CLLocation?
    @Published private(set) var placemark: CLPlacemark?
   
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    private var hasSetRegion = false;
    
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> {
        $location
            .removeDuplicates()
            .map { location in
                guard let location = location else { return nil }
                return location.coordinate
        }
        .eraseToAnyPublisher()
    }
    
    //TODO: regionPublisher
    var regionPublisher: AnyPublisher<MKCoordinateRegion, Never> {
        $region
            .map { region in
                let region = region
                return region
        }
        .eraseToAnyPublisher()
    }
  
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    private func geocode() {
        guard let location = self.location else { return }
        geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
            if error == nil {
                self.placemark = places?[0]
            } else {
                self.placemark = nil
            }
        })
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location

        if !hasSetRegion {
            self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            self.hasSetRegion = true
        }
        self.geocode()
    }
}
