import CoreLocation
import SwiftUI
import Combine
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var isAuthorized = false
    @Published var heading: CLHeading?
    @Published var cityName: String = "Detectando..."

    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Only update if moved 10 meters
        
        // Check current status
        checkAuthorizationStatus()
    }
    
    private func checkAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            locationManager.startUpdatingLocation()
        default:
            isAuthorized = false
            self.cityName = "Acceso Denegado"
        }
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.location = location
            self.reverseGeocode(location: location)
        }
    }
    
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoding Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.cityName = "Ubicación Desconocida"
                }
                return
            }
            
            guard let placemark = placemarks?.first else {
                DispatchQueue.main.async {
                    self.cityName = "Ubicación Desconocida"
                }
                return
            }
            
            self.processPlacemark(placemark)
        }
    }
    
    private func processPlacemark(_ placemark: CLPlacemark) {
        let city = placemark.locality ?? ""
        let state = placemark.administrativeArea ?? ""
        
        DispatchQueue.main.async {
            if !city.isEmpty && !state.isEmpty {
                self.cityName = "\(city), \(state)"
            } else if !city.isEmpty {
                self.cityName = city
            } else {
                self.cityName = "Ubicación Desconocida"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.heading = newHeading
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            if self.cityName == "Detectando..." {
                self.cityName = "Error de Ubicación"
            }
        }
    }
}
