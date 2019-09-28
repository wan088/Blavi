//
//  MapViewController.swift
//  Blavi
//
//  Created by Yongwan on 25/09/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var destinName: UILabel!
    @IBOutlet var Status: UILabel!
    @IBOutlet weak var Status_TV: UITextView!
    
    @IBOutlet var currentX_TF: UITextField!
    @IBOutlet var currentY_TF: UITextField!
    @IBOutlet var currentHeadingTf: UITextField!
    
    @IBOutlet var restNode: UITextField!
    
    @IBOutlet var nextNodeX_Tf: UITextField!
    @IBOutlet var nextNodeY_Tf: UITextField!
    @IBOutlet var nextNodeHeadingTf: UITextField!
    @IBOutlet weak var nextNodeDistanceTf: UITextField!
    
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
        
    }
    func rxSwiftGetNodes() -> Observable<Data>{
        return Observable.create { (observer) -> Disposable in
            return
        }
    }
    func startNavigation(){
        updateNextNode()
        self.Status.textColor = .red
        self.Status.text = "동작중"
        
        self.Status_TV.text = "길찾기 시작... \n"
        self.isStarted = true
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.currentLocation = location
        self.currentX_TF.text = "\(location.coordinate.longitude)"
        self.currentY_TF.text = "\(location.coordinate.latitude)"
        if self.isStarted{
            updateDistance(current: location)
        }
    }
    func updateDistance(current: CLLocation){
        let meter = current.distance(from: nodes[nextNode_Idx]);
        self.nextNodeDistanceTf.text = "\(Int(meter))m"
        if(meter < 10){
            self.nextNode_Idx+=1
            updateNextNode()
            if(nextNode_Idx == nodes.count){
                stopNavigation()
            }
        }
    }
    func updateNextNode(){
        self.Status_TV.text += "\(self.nextNode_Idx) 번째 노드 도착...\n"
        self.restNode.text = "\(self.nextNode_Idx) / \(self.nodes.count)개"
        let nextL = self.nodes[nextNode_Idx]
        self.nextNodeX_Tf.text = "\(nextL.coordinate.longitude)"
        self.nextNodeY_Tf.text = "\(nextL.coordinate.latitude)"
    }
    func stopNavigation(){
        self.Status_TV.text += "길찾기 완료 \n"
        self.isStarted = false
        self.Status.textColor = .green
        self.Status.text = "완료"
        self.restNode.text = ""
        self.nextNodeX_Tf.text = ""
        self.nextNodeY_Tf.text = ""
        self.nextNodeHeadingTf.text = ""
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.currentHeading = newHeading
        self.currentHeadingTf.text = "\(newHeading.magneticHeading)"
        if self.isStarted{
            setHeadingToGo()
        }
    }
    func setHeadingToGo(){
        guard let from = self.currentLocation else {return}
        let to = nodes[nextNode_Idx]
        let angle1_string = String(describing: (self.currentHeading?.magneticHeading)!)
        print(angle1_string)
        let angle1 = (Double(angle1_string))!
        let angle2 = getAngle(from: from, to: to)
        
        var nextAngle = (angle1-angle2)
        nextAngle = nextAngle > 360 ? nextAngle - 360 : nextAngle
        self.nextNodeHeadingTf.text = "\(nextAngle)"
    }
    func getAngle(from: CLLocation, to: CLLocation)->Double{
        
        var result = atan2(to.coordinate.longitude - from.coordinate.longitude , to.coordinate.latitude - to.coordinate.latitude)
        result = (result/Double.pi)*180
        return result
    }
    func initViews(){
        
        self.currentX_TF.text = self.startY
        self.currentY_TF.text = self.startX
        self.destinName.text = self.destinNameString
        self.Status_TV.layer.borderWidth = 1
        self.Status_TV.layer.borderColor = UIColor.gray.cgColor
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        
    }

}
