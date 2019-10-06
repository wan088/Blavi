//
//  MapViewController.swift
//  Blavi
//
//  Created by Yongwan on 05/10/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//

import UIKit
import NMapsMap
import CoreBluetooth
class MapViewController: UIViewController {
    var nodes: [CLLocation] = [CLLocation]()
    var mapView: NMFNaverMapView!
    var markers: [NMFMarker] = [NMFMarker]()
    var path: NMFPath!
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        print(nodes.count)
    }
    func initUI(){
        mapView = NMFNaverMapView(frame: view.frame)
        mapView.showLocationButton = true
        mapView.showCompass = true
        view.addSubview(mapView)
        initNodes()
    }
    func initNodes(){
        var idx = 1
        var lates = [NMGLatLng]()
        for node in nodes{
            var marker = NMFMarker()
            marker.position = NMGLatLng(lat: node.coordinate.latitude, lng: node.coordinate.longitude)
            marker.captionText = "\(idx)"
            idx+=1
            marker.captionTextSize = 20
            
            marker.width = 20
            marker.height = 20
            marker.mapView = mapView.mapView
            markers.append(marker)
            lates.append(NMGLatLng(from: node.coordinate))
        }
        
        path = NMFPath(points: lates)
        path.color = .red
        path.mapView = mapView.mapView
        

        
    }
}

