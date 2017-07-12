//
//  ViewController.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 12.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, WeatherGetterDelegate {

    let locationManager = CLLocationManager()
    
    var weatherGetter: WeatherGetter!
    var determineLocation = DetermineLocation()
    
    var addressFromPlacemark = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherGetter = WeatherGetter(delegate: self)
        
        determineLocation.getLocation(locationManager: locationManager, delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - WeatherGetterDelegate
    
    func didGetWeather(_ weather: Weather) {
        DispatchQueue.main.async {
            print("\nWeather: ")
            print("Data: \(weather.dateAndTime)")
            print("City: \(weather.city)")
            print("Weather description: \(weather.weatherDescription)")
            //print("Tempreture in Celsium: \(weather.tempCelsius)°")
            print("Tempreture in Celsium: \(Int(round(weather.tempCelsius)))°")
        }
    }
    
    func didNotGetWeather(_ error: NSError) {
        DispatchQueue.main.async {
            print("Cant get weather")
        }
        print("didNotGetWeather error: \(error)")

    }
    
    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("\nLocation: \n")
        print(newLocation)
        
        let myLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
        
        weatherGetter.getWeather(lon: myLocation.longitude, lat: myLocation.latitude)
        getReversedGeocodeLocation(from: newLocation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    
    func getReversedGeocodeLocation(from location: CLLocation){
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:{
            (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks != nil {
                if placemarks!.count > 0 {
                    let placemark = placemarks![0]
                    var line = ""
                    
                    // Format placemark into a string
                    line.add(text: placemark.name)
                    line.add(text: placemark.subThoroughfare, separatedBy: ", ")
                    if placemark.subThoroughfare != nil {
                        line.add(text: placemark.thoroughfare, separatedBy: " ")
                    } else {
                        line.add(text: placemark.thoroughfare, separatedBy: ", ")
                    }
                    line.add(text: placemark.locality, separatedBy: ", ")
                    line.add(text: placemark.administrativeArea, separatedBy: ", ")
                    line.add(text: placemark.postalCode, separatedBy: ", ")
                    line.add(text: placemark.country, separatedBy: ", ")
                    self.addressFromPlacemark = line
                    DispatchQueue.main.async {
                        print("\nGeocoded data: ")
                        print(self.addressFromPlacemark)
                    }
                }
                
            }
            else {
                print("Problem with the data received from geocoder")
            }
            
        })
    }


}




