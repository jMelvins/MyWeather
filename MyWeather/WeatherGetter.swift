//
//  WeatherGetter.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 12.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import Foundation

protocol WeatherGetterDelegate {
    func didGetWeather(_ weather: Weather)
    func didNotGetWeather(_ error: NSError)
}

class WeatherGetter {
    
    
    //http://api.openweathermap.org/data/2.5/weather?APPID=d6449f73f6257d124720a9b2401498d3&lat=35&lon=139
    fileprivate let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    fileprivate let openWeatherMapAPIKey = "d6449f73f6257d124720a9b2401498d3"
    fileprivate var delegate: WeatherGetterDelegate

    init(delegate: WeatherGetterDelegate) {
        self.delegate = delegate
    }

    func getWeather(lon: Double, lat: Double) {
        
        // This is a pretty simple networking task, so the shared session will do.
        let session = URLSession.shared
        
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(lat)&lon=\(lon)")!
        
        let dataTask = session.dataTask(with: weatherRequestURL as URL) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if let networkError = error {
                // Case 1: Error
                // We got some kind of error while trying to get data from the server.
                //print("Error:\n\(error)")
                self.delegate.didNotGetWeather(networkError as NSError)
            }
            else {
                // Case 2: Success
                // We got a response from the server!
                do {
                    // Try to convert that data into a Swift dictionary
                    let weatherData = try JSONSerialization.jsonObject(
                        with: data!,
                        options: .mutableContainers) as! [String: AnyObject]

                    let weather = Weather(weatherData: weatherData)
                    
                    // Now that we have the Weather struct, let's notify the view controller,
                    // which will use it to display the weather to the user.
                    self.delegate.didGetWeather(weather)
                }
                catch let jsonError as NSError {
                    // An error occurred while trying to convert the data into a Swift dictionary.
                    self.delegate.didNotGetWeather(jsonError)
                }
                
            }
        }
       
        dataTask.resume()
    }
    
    
    //MARK: - Get Icon
    
    func downloadImageFromServer(iconID: String){
        
        let iconURL = URL(string: "http://openweathermap.org/img/w/\(iconID).png")
        
        let session = URLSession(configuration: .default)
        
        let downloadPicTask = session.dataTask(with: iconURL!) {
            (data, response, error) in
            
            // The download has finished.
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded cat picture with response code \(res.statusCode)")
                    if let imageData = data {
                        
                        // Finally convert that Data into an image and do what you wish with it.
                        //let image = UIImage(data: imageData)
                        //self.image = UIImage(data: imageData)!
                        //self.imageView.image = image
                        
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
    }

}
