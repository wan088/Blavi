//
//  mapApi.swift
//  Blavi
//
//  Created by Yongwan on 28/09/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//

import UIKit
import MapKit
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
