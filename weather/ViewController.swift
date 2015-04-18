//
//  ViewController.swift
//  weather
//
//  Created by WuYanlin on 15/4/12.
//  Copyright (c) 2015年 yanlin. All rights reserved.
//

import UIKit
import CoreLocation
class ViewController: UIViewController, CLLocationManagerDelegate {
    let coreLocationManager:CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var loading: UILabel!
    
    func ios8() -> Bool {
        return UIDevice.currentDevice().systemVersion >= "8.0"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreLocationManager.delegate=self
        // Do any additional setup after loading the view, typically from a nib.
        
        coreLocationManager.desiredAccuracy=kCLLocationAccuracyBest
        
        self.loadingIndicator.startAnimating()
        
        if(ios8()) {
            coreLocationManager.requestAlwaysAuthorization()
        }
        coreLocationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count - 1 ] as! CLLocation
        if(location.horizontalAccuracy>0) {
            println (location.coordinate.latitude)
            println (location.coordinate.longitude)
            updateWeatherInfo(location.coordinate.latitude,longtitude: location.coordinate.longitude)
            coreLocationManager.stopUpdatingLocation()
        }
    }
    
    func updateWeatherInfo(latitude:CLLocationDegrees,longtitude:CLLocationDegrees) {
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let params:Dictionary = ["lat":latitude,
            "lon":longtitude,"cut":0]
        manager.GET(url, parameters:params,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in println ("JSON: "+responseObject.description)
                self.updateUISuccess(responseObject as! NSDictionary)
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in println ("Error: "+error.localizedDescription)
        })
        
    }
    
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var temperature: UILabel!
    func updateUISuccess(jsonResult:NSDictionary!) {
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.hidden=true
        loading.text=nil
        if let tempResult=(jsonResult["main"] as! NSDictionary)["temp"] as? Double {
            var temperature: Double
            if((jsonResult["sys"] as! NSDictionary)["country"] as? String == "US" ) {
                temperature = round (((tempResult - 273.15)*1.8 )+32)
                
            }
            else {
                temperature = round (tempResult-273.15)
            }
            self.temperature.text = "\(temperature)"
            self.temperature.font = UIFont.boldSystemFontOfSize(60)
            
            
            self.city.text = jsonResult["name"] as? String
            self.city.font = UIFont.boldSystemFontOfSize(30)
            
            var condition = ((jsonResult["weather"] as! NSArray)[0] as! NSDictionary)["id"] as? Int
            var sunrise = (jsonResult["sys"] as! NSDictionary)["sunrise"] as? Double
            var sunset = (jsonResult["sys"] as! NSDictionary)["sunset"] as? Double
            var nightTime = false
            var now = NSDate().timeIntervalSince1970
            if(now < sunrise || now > sunset) {
                nightTime=true
            }
            self.updateWeatherIcon(condition!, nightTime: nightTime)
        }
        else {
            loading.text="error when getting weather"
        }
    }
    
    @IBOutlet weak var icon: UIImageView!
    func updateWeatherIcon(condition: Int, nightTime: Bool) {
        if condition < 300 {
            if nightTime {
                self.icon.image = UIImage(named: "tstorm1_night")
            }
            else {
                self.icon.image = UIImage(named: "tstorm1")
            }
        }
        else if (condition < 900 && condition >= 800) {
            if nightTime {
                self.icon.image = UIImage(named: "sunny")
            }
            else {
                self.icon.image = UIImage(named: "sunny_night")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println (error)
        self.loading.text="error when geting location information"
    }


}

