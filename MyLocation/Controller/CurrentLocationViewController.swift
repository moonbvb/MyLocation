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
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }

    
    // MARK: - Methods
    // ===============
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap `Get my location` to Start"
        }
    }
    
}


// MARK: - CLLocation Manager Delegate Extension
extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    // Ошибка при обновлении локации locationManager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error.localizedDescription)")
    }
    
    // Удачное обновление локации locationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocation \(newLocation)")
        
        location = newLocation
        updateLabels()
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
