// Экран текущей локации
//
//  CurrentLocationViewController.swift
//  MyLocation
//
//  Created by DenisSuspitsyn on 21.09.2020.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {
    
    // MARK: - Outlets
    // ===============
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    
    // MARK: - Properties
    // ==================
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    var updatingLocation = false
    var lastLocationError: Error?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    
    // MARK: - ViewDidLoad
    // ===================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    
    // MARK: - Actions
    // ===============
    
    @IBAction func getLocation() {
        // Отправка запрос для получения разрешения на получение геоданных_
        let authStatus = locationManager.authorizationStatus
        // _при authorizationStatus == .notDetermined
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // При закрытом досутпе к локации вызывает алерт с просьбой открыть доступ
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
        
        updateLabels()
    }
    
    
    // MARK: - Methods
    
    
    // MARK: Labels
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            let statusMessage: String
            
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Service Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap `Get my location` to Start"
            }
            
            messageLabel.text = statusMessage
            configureGetButton()
        }
    }
    
    // MARK: Buttons
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    // MARK: LocationManager
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
}


// MARK: - CLLocation Manager Delegate Extension
extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    // Ошибка при обновлении локации locationManager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue { return }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    // Удачное обновление локации locationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocation \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 { return }
        
        if newLocation.horizontalAccuracy < 0 { return }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We`re done!")
                stopLocationManager()
            }
            updateLabels()
            
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
                    if let error = error {
                        print("*** Reverse Geocoding error: \(error.localizedDescription)")
                        return
                    }
                    if let places = placemarks {
                        print("*** Found places: \(places)")
                    }
                }
            }
        }
    }
    
}


// MARK: - Helper Methods Extension
extension CurrentLocationViewController {
    
    // Показывает alert с просьбой включить доступ к location services
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings.",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}
