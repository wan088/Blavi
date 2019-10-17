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
import AVFoundation
import CoreBluetooth
class CheckViewController: UIViewController, CLLocationManagerDelegate {
    
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
    
    var avss = AVSpeechSynthesizer()
    lazy var voiceNavi: Timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
        DispatchQueue.main.async {
            if(Double(self.currentHeadingTf.text!)! > 180){
                self.say(str: "오른쪽")
            }else{
                self.say(str: "왼쪽")
            }
        }
    }
        
    @IBAction func findRoute(_ sender: Any) {
        self.nodes = [CLLocation]()
        _ = rxSwiftGetNodes(startX: startX, startY: startY, endX: endX, endY: endY).observeOn(MainScheduler.instance).subscribe { (event) in
            switch event{
            case let .next(data):
                self.initNodes(data: data)
            case let .error(error):
                print(error.localizedDescription)
            case let .completed:
                break
            }
        }
        
        let alert = UIAlertController(title: "길 찾기 시작", message: "해당 경로로 길찾기를 실행합니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "시작", style: .default) { (action) in
            alert.dismiss(animated: true) {
                self.startNavigation()
                
                DispatchQueue.main.async {
                    self.say(str: "안내를 시작합니다")
                }
                
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel){(_) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true)
        
    }
    func initNodes(data: Data){
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
            }
    }
    func startNavigation(){
        updateNextNode()
        self.Status.textColor = .red
        self.Status.text = "동작중"
        self.voiceNavi.fireDate = Date().addingTimeInterval(3)
        self.voiceNavi.fire()
        
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
        self.voiceNavi.invalidate()
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
        let mapBtn = UIBarButtonItem()
        mapBtn.title = "Map"
        mapBtn.target = self
        mapBtn.action = #selector(mapBtnToched(_:))
        self.navigationItem.rightBarButtonItem = mapBtn
    }
    @objc
    func mapBtnToched(_ sender: Any){
        let mvc = MapViewController()
        mvc.nodes = self.nodes
        self.show(mvc, sender: self)
    }
    func say(str: String){
        var ut = AVSpeechUtterance(string: str)
        ut.rate = 0.4
        ut.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        self.avss.speak(ut)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    deinit {
        print("뿌와앗")
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.voiceNavi.invalidate()
    }

}
