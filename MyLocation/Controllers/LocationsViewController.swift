//
//  LocationsViewController.swift
//  MyLocation
//
//  Created by DenisSuspitsyn on 01.10.2020.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    
    // MARK: - Properties
    
    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()
    
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<Location>()
        let entity = Location.entity()
        fetchRequest.entity = entity
        let sortDesctriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDesctriptor]
        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    
}


// MARK: - Table View Delegates

extension LocationsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        let location = locations[indexPath.row]
        
        let desctiptionLabel = cell.viewWithTag(100) as! UILabel
        desctiptionLabel.text = location.locationDescription
        
        let addressLabel = cell.viewWithTag(101) as! UILabel
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare { text += s + " " }
            if let s = placemark.subThoroughfare { text += s + " " }
            if let s = placemark.locality        { text += s + " " }
            addressLabel.text = text
        } else {
            addressLabel.text = ""
        }
        
        return cell
    }
}
