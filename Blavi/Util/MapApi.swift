//
//  mapApi.swift
//  Blavi
//
//  Created by Yongwan on 28/09/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
// MARK:  키워드 검색 결과
func getResults(currentLocation: CLLocation, keyword: String,  completion:  @escaping (Data)->Void){
    let urlString = "https://naveropenapi.apigw.ntruss.com/map-place/v1/search?query=\(keyword)&coordinate=\(currentLocation.coordinate.longitude),\(currentLocation.coordinate.latitude)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
    guard let url = URL(string:urlString) else{
        print("Error : Wrong URL")
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("xxp3z85qgy", forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
    request.addValue("OlejTqWkxVCIkrAj3nWf6a3jtVrvvlQNO0u4CdRh", forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
    let task = URLSession.shared.dataTask(with: request){(data, response, error) in
        if let e = error{
            print("Error :",e.localizedDescription)
            return
        }
        if let data = data{
            completion(data)
            return
        }
    }
    task.resume()
}
func rxSwiftGetLocations(keyword: String, location:CLLocation) -> Observable<Data>{
    return Observable<Data>.create { (observer) -> Disposable in
        getResults(currentLocation: location, keyword: keyword) { (data) in
            observer.onNext(data)
            observer.onCompleted()
        }
        return Disposables.create()
    }
}
// MARK:  보행자 경로 노드 가져오기
func getNodeDatas(startX: String, startY: String, endX: String, endY: String,  completion: @escaping (Data)->Void){
    guard let url = URL(string: "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1") else {return}
    
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
            completion(data)
        }
    }.resume()
}
func rxSwiftGetNodes(startX: String, startY: String, endX: String, endY: String) -> Observable<Data>{
    return Observable.create { (observer) -> Disposable in
        getNodeDatas(startX: startX, startY: startY, endX: endX, endY: endY) { (data) in
            observer.onNext(data)
            observer.onCompleted()
        }
        return Disposables.create()
    }
}
