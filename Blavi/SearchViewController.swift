//
//  ViewController.swift
//  Blavi
//
//  Created by Yongwan on 11/09/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//
import MapKit
import UIKit
import RxSwift
import RxCocoa
class SearchViewController: UIViewController, CLLocationManagerDelegate{
    
    var places: [Place] = [Place]()
    var locationManager: CLLocationManager?
    var disposeBag = DisposeBag()
    
    @IBOutlet var ResultTableView: UITableView!
    @IBOutlet var SearchTF: UITextField!
    @IBOutlet var SearchBtn: UIButton!
    @IBAction func SearchTouch(_ sender: Any) {
        guard let text = SearchTF.text else{return}
        guard let location = locationManager?.location else {return}
        if(text == ""){return}
        rxSwiftGetLocations(keyword: text, location: location).observeOn(MainScheduler.instance).subscribe { (event) in
            switch event{
            case let .next(data):
                self.fillTableView(data: data);
            case let .error(error):
                print(error.localizedDescription)
            case .completed:
                break
            }
        }.disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ResultTableView.dataSource = self
        self.ResultTableView.delegate = self
        SearchTF.delegate = self
        
        self.SearchTF.rx.text.orEmpty.debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).distinctUntilChanged().filter{ !$0.isEmpty
            }.subscribe { (event) in
            switch event{
            case let .next(_):
                print("search 요청")
                self.SearchTouch(self)
            case let .error(error):
                print(error.localizedDescription)
            case .completed:
                break
            }
        }
        initLocationManager()
    }
    func initLocationManager(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.startUpdatingHeading()
    }
    func fillTableView(data: Data){
        do{
            let w = try JSONDecoder().decode(Search_Result.self, from: data)
            self.places = w.places
            self.ResultTableView.reloadData()
        }catch{
            print("Decode Error")
        }
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
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "mapVC") as! CheckViewController
        mapVC.endX = self.places[indexPath.row].x
        mapVC.endY = self.places[indexPath.row].y
        guard let currentLocation = locationManager?.location else {return}
        mapVC.startX = "\(currentLocation.coordinate.longitude)"
        mapVC.startY = "\(currentLocation.coordinate.latitude)"
        mapVC.destinNameString = self.places[indexPath.row].name
        
        self.locationManager?.delegate = mapVC
        //self.locationManager?.stopUpdatingHeading()
        self.navigationController?.pushViewController(mapVC, animated: true)
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
    }
}
extension SearchViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.SearchTouch(self)
        textField.resignFirstResponder()
        return true
    }
}
