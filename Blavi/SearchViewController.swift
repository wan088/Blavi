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
import Speech
class SearchViewController: UIViewController, CLLocationManagerDelegate{
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    @IBAction func micBtn(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
       
        } else {
            startRecording()
        }
    }
     func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.SearchTF.text = result?.bestTranscription.formattedString
                self.SearchTouch(self)
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        
    }
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
        initSpeeches()
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
    func initSpeeches(){
         speechRecognizer?.delegate = self
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
extension SearchViewController: SFSpeechRecognizerDelegate{
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print(available)
    }
}
