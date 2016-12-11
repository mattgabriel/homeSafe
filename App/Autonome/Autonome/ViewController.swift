//
//  ViewController.swift
//  Autonome
//
//  Created by Matt Gabriel on 10/12/2016.
//  Copyright © 2016 Matt Gabriel. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, SensorViewProtocol, MapViewProtocol {

    var logo = UIImageView()
    
    var Sound_1: [Int] = []
    var Temperature_1: [Int] = []
    var Light_1: [Int] = []
    var Humidity_1: [Int] = []
    var AirQuality_1: [Int] = []
    
    var timer = Timer()
    var isTimerValid: Bool = false
    
    //views
    var stateLabel = UILabel()
    var sensorsView = SensorsView()
    var mapView = MapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = Design.Color.green
        logo = UIImageView(frame: CGRect(x: 0, y: 20, width: view.frame.size.width, height: 180))
        logo.image = UIImage(named: "logo_longer.png")
        logo.contentMode = .scaleAspectFit
        self.view.addSubview(logo)
        
        buildState()
        buildSensorView()
        
        setState(isWarning: false)
    }
    
    func stoptimer(){
        isTimerValid = false
        timer.invalidate()
    }
    
    func startTimer(){
        stoptimer()
        isTimerValid = true
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.reloadData), userInfo: nil, repeats: true)
    }
    
    func reloadData(){
        loadData()
    }
    
    func makeCall(phone: String) {
        if let url = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func showMap(){
        let initialFrame = CGRect(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: 500)
        let finalFrame = CGRect(x: 0, y: view.frame.size.height-500, width: view.frame.size.width, height: 500)
        mapView = MapView(frame: initialFrame)
        mapView.delegate = self
        self.view.addSubview(mapView)
        UIView.animate(withDuration: 0.4, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.mapView.frame = finalFrame
        }, completion: nil)
    }
    
    func buildSensorView(){
        loadData()
        startTimer()
    }
    
    func buttonTapped() {
        stoptimer()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.setState(isWarning: true)
            self.sensorsView.frame.origin.y = self.view.frame.size.height
            self.showMap()
        }, completion: {
            (complete: Bool) in
            self.sensorsView.removeFromSuperview()
        })
    }
    
    func button1Tapped() {
        stoptimer()
        makeCall(phone: "09008844")
    }
    
    func button2Tapped() {
        stoptimer()
        makeCall(phone: "+41772724155")
    }
    
    func buttonHiddenTapped() {
        startTimer()
        UIView.animate(withDuration: 0.4, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.mapView.frame.origin.y = self.view.frame.size.height
        }, completion: {
            (complete: Bool) in
            self.buildSensorView()
            self.setState(isWarning: false)
        })
    }
    
    func buildState(){
        stateLabel = UILabel(frame: CGRect(x: 0, y: 180, width: view.frame.size.width, height: 80))
        stateLabel.textColor = UIColor.white
        stateLabel.textAlignment = .center
        stateLabel.font = Design.Font.superSizeSmall
        stateLabel.text = "SAFE"
        self.view.addSubview(stateLabel)
    }
    
    func setState(isWarning: Bool){
        if isWarning {
            stateLabel.text = "WARNING!"
            self.view.backgroundColor = Design.Color.red
        } else {
            stateLabel.text = "SAFE"
            self.view.backgroundColor = Design.Color.green
        }
    }
    
    func loadData(){
        if !isTimerValid {
            return
        }
        Sound_1 = []
        Temperature_1 = []
        Light_1 = []
        Humidity_1 = []
        AirQuality_1 = []
        Alamofire.request("http://52.57.102.57/api/sensor/0/12312312312/100").validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value as? [String: AnyObject] {
                    if let data = json["Data"] as? [AnyObject] {
                        for i in 0...data.count-1 {
                            
                            var _sensorId = ""
                            if let sensorId = data[i]["SensorId"] as? String {
                                _sensorId = sensorId
                            }
                            
                            var _value: Int = -1
                            if let value = data[i]["Value"] as? Int {
                                _value = value
                            }
                            
//                            var _time: String = ""
//                            if let time = data[i]["Timestamp"] as? String {
//                                _time = time
//                            }
                            
                            //populate arrays
                            if _sensorId == "Temperature_1" {
                                self.Temperature_1.append(_value)
                            }
                            if _sensorId == "Sound_1" {
                                self.Sound_1.append(_value)
                            }
                            if _sensorId == "Light_1" {
                                //print("\(_value) \(_time)")
                                self.Light_1.append(_value)
                            }
                            if _sensorId == "Humidity_1" {
                                self.Humidity_1.append(_value)
                            }
                            if _sensorId == "AirQuality_1" {
                                self.AirQuality_1.append(_value)
                            }
                            
                        }
                        
//                        self.Temperature_1.reverse()
//                        self.Sound_1.reverse()
//                        self.Light_1.reverse()
//                        self.Humidity_1.reverse()
//                        self.AirQuality_1.reverse()
//
//                        print(self.Temperature_1)
//                        print(self.Sound_1.first!)
//                        print(self.Light_1)
//                        print(self.Humidity_1.first!)
//                        print(self.AirQuality_1.first!)
                        
                        DispatchQueue.main.async {
                            self.sensorsView.removeFromSuperview()
                            self.sensorsView = SensorsView(frame: CGRect(x: 0, y: 300, width: self.view.frame.size.width, height: self.view.frame.size.height-300))
                            self.sensorsView.delegate = self
                            self.view.addSubview(self.sensorsView)
                            self.sensorsView.buildSquare(title: "Temperature", value: "\(self.Temperature_1.first!-8)C", col: 0, row: 0, isBad: false)
                            self.sensorsView.buildSquare(title: "Brightness", value: "\(self.Light_1.first!)%", col: 1, row: 0, isBad: false)
                            self.sensorsView.buildSquare(title: "Humidity", value: "\(self.Humidity_1.first!)%", col: 0, row: 1, isBad: false)
                            self.sensorsView.buildSquare(title: "Last Movement", value: "2hr", col: 1, row: 1, isBad: false)
                            self.sensorsView.buildSquare(title: "Air Quality", value: "Ok", col: 0, row: 2, isBad: false)
                            self.sensorsView.buildSquare(title: "Loudness", value: "\(self.Sound_1.first!)%", col: 1, row: 2, isBad: false)
                            self.sensorsView.addButton()
                        }
                    }

                }
            case .failure(let error):
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

