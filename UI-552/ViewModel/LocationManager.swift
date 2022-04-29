//
//  LocationManager.swift
//  UI-552
//
//  Created by nyannyan0328 on 2022/04/29.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

class LocationManager: NSObject,ObservableObject,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @Published var searchText : String = ""
    
    @Published var mapView : MKMapView = .init()
    @Published var manager : CLLocationManager = .init()
    
    @Published var fetchPlaces : [CLPlacemark]?
    @Published var userLocations : CLLocation?
    
    @Published var pickedLocation : CLLocation?
    @Published var pickedPlaceMark : CLPlacemark?
    
    
    var casellable : AnyCancellable?
    
    
    override init() {
        
        super.init()
        
        mapView.delegate = self
        manager.delegate = self
        
        manager.requestWhenInUseAuthorization()
        
        
        casellable = $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: {[self] value in
                
                if value != ""{
                    
                    fetchPlaces(value: value)
                    
                    
                }
                else{
                    
                    fetchPlaces = nil
                    
                    
                }
            })
        
        
    }
    
    func fetchPlaces(value : String){
        
        Task{
            do{
                
                let request = MKLocalSearch.Request()
                
                request.naturalLanguageQuery = value.lowercased()
                
                let responce = try await MKLocalSearch(request: request).start()
                
                await MainActor.run(body: {
                    self.fetchPlaces = responce.mapItems.compactMap({ item -> CLPlacemark? in
                        
                        
                        return item.placemark
                    })
                    
                })
                
            }
            catch{}
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let currentLocation = locations.last else{return}
        
        self.userLocations = currentLocation
    }
    
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus{
        case .authorizedAlways : manager.requestLocation()
        case.authorizedWhenInUse : manager.requestLocation()
        case .denied : hadleError()
        case .notDetermined : manager.requestWhenInUseAuthorization()
        default : ()
      
        }
        
    }
    
    
    
    func hadleError(){}
    
    func addDraggPin(cordinate : CLLocationCoordinate2D){
        
        let anotation = MKPointAnnotation()
        anotation.coordinate = cordinate
        anotation.title = "MAXIMAM"
        
        mapView.addAnnotation(anotation)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "FINAL")
        marker.isDraggable = true
        marker.canShowCallout = true
        
        return marker
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        
        guard let newLocation = view.annotation?.coordinate else{return}
        
        self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        updatePlaceMark(location: .init(latitude: newLocation.latitude, longitude: newLocation.longitude))
        
    }
    
    func updatePlaceMark(location : CLLocation){
        
        Task{
            
            do{
                
                guard let place = try await reveceLocationCoordinates(location: location) else{return}
                
                await MainActor.run(body: {
                    
                    self.pickedPlaceMark = place
                })
                
            }
            catch{}
        }
        
    }
    
    func reveceLocationCoordinates(location : CLLocation) async throws->CLPlacemark?{
        
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        
        return place
        
    }
}


