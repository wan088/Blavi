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
    @IBOutlet var tmpLabel: UILabel!
    
    var currentLocation: CLLocation?
    var currentHeading: CLHeading?
    var nodes: [CLLocation] = [CLLocation]()
    
    var startX = ""
    var startY = ""
    
    var endX = ""
    var endY = ""
    
    
    let RouteSearchUrlString = "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1"
    @IBAction func findRoute(_ sender: Any) {
        guard let url = URL(string: RouteSearchUrlString) else {return}
        self.tmpLabel.text = "startX : \(startX)\n startY :\(startY) \n \(endX),\n \(endY)"
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("e63a4c30-d4cd-4cee-bac8-f5c55a0e9ce9", forHTTPHeaderField: "appKey")
        
        let jsonData: [String: Any] = [
            "startX" : startX,
            "startY" : startY,
            "endX" : endX,
            "endY" : endY,
            "startName" : "start",
            "endName" : "end",
        ]
        
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: jsonData, options: [])
        
        URLSession.shared.dataTask(with: request) { (data, res, error) in
            
            if let data = data{
                //print(String(data: data, encoding: .utf8))
                let featureCollection = try! JSONDecoder().decode(FeatureCollection.self, from: data)
                for features in featureCollection.features{
                    let long = features.geometry.coordinates[0]
                    let lat = features.geometry.coordinates[1]
                    print(long)
                    print(lat)
                }
            }
        }.resume()
        
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
