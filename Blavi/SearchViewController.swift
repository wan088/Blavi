//
//  ViewController.swift
//  Blavi
//
//  Created by Yongwan on 11/09/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//
import MapKit
import UIKit
class SearchViewController: UIViewController, CLLocationManagerDelegate{
    
    var places: [Place] = [Place]()
    var locationManager: CLLocationManager?
    
    @IBOutlet var ResultTableView: UITableView!
    @IBOutlet var SearchTF: UITextField!
    @IBOutlet var SearchBtn: UIButton!
    @IBAction func SearchTouch(_ sender: Any) {
        if let text = SearchTF.text{
            if(text != ""){
                fillTableView(keyword: text)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ResultTableView.dataSource = self
        SearchTF.delegate = self
        initLocationManager()
    }
    func initLocationManager(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.startUpdatingHeading()
    }
    func fillTableView(keyword: String){
        let Search_Keyword = SearchTF.text!
        guard let Current_Location = locationManager?.location?.coordinate else{
            let alert = UIAlertController(title: "위치확인 오류", message: "현재 위치를 확인할 수 없습니다.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(ok)
            self.present(alert, animated: true)
            return
        }
        
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-place/v1/search?query=\(Search_Keyword)&coordinate=\(Current_Location.longitude),\(Current_Location.latitude)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
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
                    self.places = w.places
                    self.ResultTableView.reloadData()
                }catch{
                    print("Decode Error")
                }
                
            }
        }
        task.resume()
    }
}
extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(places.count)
        return self.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = self.places[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell") ?? UITableViewCell(style: .default, reuseIdentifier: "placeCell")
        cell.textLabel?.text = place.name
        return cell
    }
}
extension SearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.storyboard?.instantiateViewController(withIdentifier: "mapVC")
        
    }
}
extension SearchViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = SearchTF.text{
            if(text != ""){
                fillTableView(keyword: text)
            }
        }
        textField.resignFirstResponder()
        return true
    }
}
