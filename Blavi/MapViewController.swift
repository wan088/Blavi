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
    @IBOutlet var destinName: UILabel!
    @IBOutlet var Status: UILabel!
    
    
    @IBOutlet var currentX_TF: UITextField!
    @IBOutlet var currentY_TF: UITextField!
    @IBOutlet var currentHeadingTf: UITextField!
    
    @IBOutlet var restNode: UITextField!
    
    @IBOutlet var nextNodeX_Tf: UITextField!
    @IBOutlet var nextNodeY_Tf: UITextField!
    @IBOutlet var nextNodeHeadingTf: UITextField!
    
    var currentLocation: CLLocation?
    var currentHeading: CLHeading?
    var nodes: [CLLocation] = [CLLocation]()
    
    var destinNameString: String?
    var startX = ""
    var startY = ""
    var endX = ""
    var endY = ""
    
    var nextNode_Idx = 0
    var isStarted = false
    
    let RouteSearchUrlString = "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1"
    @IBAction func findRoute(_ sender: Any) {
        guard let url = URL(string: RouteSearchUrlString) else {return}
        
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
                
                //let featureCollection = try! JSONDecoder().decode(FeatureCollection.self, from: data)
                let featureCollection = try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                let feats = featureCollection["features"] as! [[String: Any]]
            
                for tmp in feats{
                    let feat = tmp as! [String:Any]
                    let geo = feat["geometry"] as! [String: Any]
                    if geo["type"] as! String == "LineString"{
                        continue
                    }
                    let coors = geo["coordinates"] as! NSArray
                    let lat = coors[1] as! CFNumber
                    let long = coors[0] as! CFNumber
                    
                    self.nodes.append(CLLocation(latitude: Double(lat), longitude: Double(long) ))
                    
                    self.nextNode_Idx = 0
                    DispatchQueue.main.async {
                        self.startNavigation()
                        
                    }
                    
                }
            }
        }.resume()
        
    }
    func startNavigation(){
        self.restNode.text = "\(self.nextNode_Idx+1) / \(self.nodes.count)개"
        let nextL = self.nodes[nextNode_Idx]
        self.nextNodeX_Tf.text = "\(nextL.coordinate.longitude)"
        self.nextNodeY_Tf.text = "\(nextL.coordinate.latitude)"
        self.Status.textColor = .red
        self.Status.text = "동작중"
        self.isStarted = true
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.currentLocation = location
        self.currentX_TF.text = "\(location.coordinate.longitude)"
        self.currentY_TF.text = "\(location.coordinate.latitude)"
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.currentHeading = newHeading
        self.currentHeadingTf.text = "\(newHeading.magneticHeading)"
        if self.isStarted{
            updateNavigation()
        }
    }
    func updateNavigation(){
        guard let from = self.currentLocation else {return}
        let to = CLLocation(latitude: Double(self.endY)!, longitude: Double(self.endX)!)
        let angle1_string = String(describing: (self.currentHeading?.magneticHeading)!)
        print(angle1_string)
        let angle1 = (Double(angle1_string))!
        let angle2 = getAngle(from: from, to: to)
        
        var nextAngle = (angle1-angle2)
        nextAngle = nextAngle > 360 ? nextAngle - 360 : nextAngle
        self.nextNodeHeadingTf.text = "\(nextAngle)"
    }
    func getAngle(from: CLLocation, to: CLLocation)->Double{
        var result = atan2(to.coordinate.longitude - from.coordinate.longitude , to.coordinate.latitude - to.coordinate.longitude)
        result = (result/Double.pi)*180
        return result
    }
    func initViews(){
        
        self.currentX_TF.text = self.startY
        self.currentY_TF.text = self.startX
        self.destinName.text = self.destinNameString
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        
    }
}
