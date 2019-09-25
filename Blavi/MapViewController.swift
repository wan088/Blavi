//
//  MapViewController.swift
//  Blavi
//
//  Created by Yongwan on 25/09/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController, CLLocationManagerDelegate {
    var currentLocation: CLLocation?
    var currentHeading: CLHeading?
    
    var startLocation: CLLocation?
    var endLocation: CLLocation?
    
    let RouteSearchUrlString = "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1"
    @IBAction func findRoute(_ sender: Any) {
        guard let url = URL(string: RouteSearchUrlString) else {return}
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.currentHeading = newHeading
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
