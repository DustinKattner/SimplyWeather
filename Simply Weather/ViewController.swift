//
//  ViewController.swift
//  Simply Weather
//
//  Created by Dustin Kattner on 9/20/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let apiKey = "eed3d9a414872d379b242fc11f447bfc"
    var latitude = 11.1111
    var longitude = 11.1111
    var activityIndicator: NVActivityIndicatorView!
    var locationManager = CLLocationManager()
    
    // Outlets
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var conditionImg: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempUnitsLabel: UILabel!
    @IBOutlet var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        locationManager.requestWhenInUseAuthorization()
        
        activityIndicator.startAnimating()
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    // location manager function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial").responseJSON(completionHandler: {
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let iconName = jsonWeather["icon"].stringValue
                
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.conditionImg.image = UIImage(named: iconName)
                self.conditionLabel.text = jsonWeather["main"].stringValue
                self.tempLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                
                let suffix = iconName.suffix(1)
                if(suffix == "n"){
                    self.setBackground("Night")
                }else{
                    self.setBackground("Day")
                }
            }
        })
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    // change background
    func setBackground(_ tod: String){
        if tod == "day" || tod == "Day"{
            backgroundView.backgroundColor = .systemBlue
        }
        else{
            backgroundView.backgroundColor = .black
        }
    }
    
}

