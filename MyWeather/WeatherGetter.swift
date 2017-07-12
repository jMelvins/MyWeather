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

    func getWeather(lon: Double, lat: Double) {
        
        // This is a pretty simple networking task, so the shared session will do.
        let session = URLSession.shared
        
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(lat)&lon=\(lon)")!
        
        let dataTask = session.dataTask(with: weatherRequestURL as URL) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                // Case 1: Error
                // We got some kind of error while trying to get data from the server.
                print("Error:\n\(error)")
            }
            else {
                // Case 2: Success
                // We got a response from the server!
                print("Raw data:\n\(data!)\n")
                let dataString = String(data: data!, encoding: String.Encoding.utf8)
                print("Human-readable data:\n\(dataString!)")
//                do {
//                    // Try to convert that data into a Swift dictionary
//                    let weatherData = try JSONSerialization.jsonObject(
//                        with: data!,
//                        options: .mutableContainers) as! [String: AnyObject]
//                    
//                    // If we made it to this point, we've successfully converted the
//                    // JSON-formatted weather data into a Swift dictionary.
//                    // Let's now used that dictionary to initialize a Weather struct.
//                    let weather = Weather(weatherData: weatherData)
//                    
//                    // Now that we have the Weather struct, let's notify the view controller,
//                    // which will use it to display the weather to the user.
//                    self.delegate.didGetWeather(weather)
//                }
//                catch let jsonError as NSError {
//                    // An error occurred while trying to convert the data into a Swift dictionary.
//                    self.delegate.didNotGetWeather(jsonError)
//                }
                
            }
        }
        
        // The data task is set up...launch it!
        dataTask.resume()
    }
    
    
    func getWeather(city: String) {
        
        // This is a pretty simple networking task, so the shared session will do.
        let session = URLSession.shared
        
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        
        let dataTask = session.dataTask(with: weatherRequestURL as URL) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                // Case 1: Error
                // We got some kind of error while trying to get data from the server.
                print("Error:\n\(error)")
            }
            else {
                // Case 2: Success
                // We got a response from the server!
                print("Raw data:\n\(data!)\n")
                let dataString = String(data: data!, encoding: String.Encoding.utf8)
                print("Human-readable data:\n\(dataString!)")
                //                do {
                //                    // Try to convert that data into a Swift dictionary
                //                    let weatherData = try JSONSerialization.jsonObject(
                //                        with: data!,
                //                        options: .mutableContainers) as! [String: AnyObject]
                //
                //                    // If we made it to this point, we've successfully converted the
                //                    // JSON-formatted weather data into a Swift dictionary.
                //                    // Let's now used that dictionary to initialize a Weather struct.
                //                    let weather = Weather(weatherData: weatherData)
                //
                //                    // Now that we have the Weather struct, let's notify the view controller,
                //                    // which will use it to display the weather to the user.
                //                    self.delegate.didGetWeather(weather)
                //                }
                //                catch let jsonError as NSError {
                //                    // An error occurred while trying to convert the data into a Swift dictionary.
                //                    self.delegate.didNotGetWeather(jsonError)
                //                }
                
            }
        }
        
        // The data task is set up...launch it!
        dataTask.resume()
    }
}
