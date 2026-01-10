//
//  LocationService.swift
//  AppTemplate
//
//  Location services and search - reusable across apps
//

import Foundation
import CoreLocation
import MapKit

/// Service for handling location-related functionality
class LocationService: NSObject, ObservableObject {
    
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var currentCity: String?
    @Published var currentCountry: String?
    @Published var isLoading = false
    @Published var error: String?
    
    private var locationCompletion: ((String?, String?) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // City-level accuracy is fine
        authorizationStatus = locationManager.authorizationStatus
    }
    
    /// Request location permission and get current location
    func requestCurrentLocation(completion: @escaping (String?, String?) -> Void) {
        self.locationCompletion = completion
        self.error = nil
        self.isLoading = true
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            self.isLoading = false
            self.error = "Location access denied. Please enable in Settings."
            completion(nil, nil)
        @unknown default:
            self.isLoading = false
            completion(nil, nil)
        }
    }
    
    /// Reverse geocode coordinates to city/country
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = "Could not determine location: \(error.localizedDescription)"
                    self?.locationCompletion?(nil, nil)
                    return
                }
                
                if let placemark = placemarks?.first {
                    let city = placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea
                    let country = placemark.country
                    
                    self?.currentCity = city
                    self?.currentCountry = country
                    self?.locationCompletion?(city, country)
                } else {
                    self?.locationCompletion?(nil, nil)
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        reverseGeocode(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.error = "Location error: \(error.localizedDescription)"
            self.locationCompletion?(nil, nil)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            if locationCompletion != nil {
                locationManager.requestLocation()
            }
        }
    }
}

// MARK: - Location Search Completer

/// Handles location autocomplete suggestions
class LocationSearchCompleter: NSObject, ObservableObject {
    
    @Published var suggestions: [MKLocalSearchCompletion] = []
    @Published var isSearching = false
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func search(query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        isSearching = true
        completer.queryFragment = query
    }
    
    func clear() {
        suggestions = []
    }
    
    /// Get city and country from a search completion
    func getLocationDetails(from completion: MKLocalSearchCompletion, result: @escaping (String?, String?) -> Void) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let placemark = response?.mapItems.first?.placemark else {
                result(nil, nil)
                return
            }
            
            let city = placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea
            let country = placemark.country
            
            DispatchQueue.main.async {
                result(city, country)
            }
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationSearchCompleter: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.isSearching = false
            // Filter to show only city-level results
            self.suggestions = completer.results.filter { result in
                // Exclude specific addresses (those with street numbers)
                !result.title.contains(where: { $0.isNumber && result.title.first?.isNumber == true })
            }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isSearching = false
        }
    }
}

