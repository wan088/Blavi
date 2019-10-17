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
import AVFoundation
import AudioToolbox
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
            SearchBtn.isEnabled = false
            startRecording()
        }
    }
    
    var avss = AVSpeechSynthesizer()
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
    func bindTf(){
        self.SearchTF.rx.text.orEmpty.debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).distinctUntilChanged().filter{ !$0.isEmpty
            }.subscribe { (event) in
            switch event{
            case let .next(_):
                self.SearchTouch(self)
            case let .error(error):
                print(error.localizedDescription)
            case .completed:
                break
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ResultTableView.dataSource = self
        self.ResultTableView.delegate = self
        SearchTF.delegate = self
        initSpeeches()
        bindTf()
        initLocationManager()
        //say(str: "검색을 원하면 아래로 쓸어내리세요")
        initRefresh()
    }
    func initRefresh(){
        var refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(updateAndSearchTable(refresh:)), for: .valueChanged)
        self.ResultTableView.refreshControl = refresh
    }
    @objc
    func updateAndSearchTable(refresh: UIRefreshControl){
        refresh.endRefreshing()
        if(!audioEngine.isRunning){
            self.micBtn(self)
        }
    }
    func say(str: String){
        var ut = AVSpeechUtterance(string: str)
        ut.rate = 0.4
        ut.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        self.avss.speak(ut)
    }
    func initSpeeches(){
         //speechRecognizer?.delegate = self
    }
    // MARK:  Location
    func initLocationManager(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.startUpdatingHeading()
        locationManager?.allowsBackgroundLocationUpdates = true
        
    }
    // MARK:  TableView
    func fillTableView(data: Data){
        do{
            let w = try JSONDecoder().decode(Search_Result.self, from: data)
            self.places = w.places
            self.ResultTableView.reloadData()
        }catch{
            print("Decode Error")
        }
    }
    // MARK:  Mic-Record
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
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
        AudioServicesPlaySystemSound(1007)
        audioEngine.prepare()
        do {
            try audioEngine.start()
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
                self.audioEngine.stop()
                recognitionRequest.endAudio()
                self.SearchBtn.isEnabled = true
            }
        } catch {
            print("audioEngine couldn't start because of an error.")
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
        cell.accessibilityValue = place.name
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
//extension SearchViewController: SFSpeechRecognizerDelegate{
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        print(available)
//    }
//}
