//
//  ViewController.swift
//  Blavi
//
//  Created by Yongwan on 11/09/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//
import MapKit
import UIKit
import NMapsMap

class ViewController: UIViewController {
    @IBOutlet var SearchTF: UITextField!
    @IBOutlet var SearchBtn: UIButton!
    @IBOutlet var SearchResult: UILabel!
    @IBAction func SearchTouch(_ sender: Any) {
        if(SearchTF.text == nil || SearchTF.text == ""){
            return
        }
        let Search_Keyword = SearchTF.text!
        let Current_Location = getCurrentLocation()
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-place/v1/search?query=\(Search_Keyword)&coordinate=\(Current_Location)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
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
            DispatchQueue.main.async {
                let w: Search_Result
                do{
                    w = try JSONDecoder().decode(Search_Result.self, from: data!)
                    print(w.places[0].name)
                }catch{
                    print("Decode Error")
                }
            
            }
        }
        task.resume()
    }
    func getCurrentLocation() -> String{
        return "127.1054328,37.3595963"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

