//
//  ViewController.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 12.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentWeatherViewController: UIViewController, CLLocationManagerDelegate, WeatherGetterDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var mainWeather: UILabel!
    
    
    let locationManager = CLLocationManager()
    var location: CLLocation? = nil
    var weatherDesc: Weather?
    
    var weatherGetter: WeatherGetter!
    var determineLocation = DetermineLocation()
    
    var addressFromPlacemark = ""
    var image = UIImage()

    //Добавляем спиннер программно
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherGetter = WeatherGetter(delegate: self)
        
        
        longitudeLabel.text = "-"
        latitudeLabel.text = "-"
        addressLabel.text = "Wait. We're trying to determine your location."
        iconLabel.text = ""
        tempretureLabel.text = ""
        mainWeather.text = ""
        
        if view.viewWithTag(1000) == nil {
            spinner.center = addressLabel.center
            spinner.center.y += spinner.bounds.size.height/2 + 20
            spinner.startAnimating()
            spinner.tag = 1000
            view.addSubview(spinner)
        }
        
        //determineLocation.getLocation(locationManager: locationManager, delegate: self)
        getLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - WeatherGetterDelegate
    
    func didGetWeather(_ weather: Weather) {
        DispatchQueue.main.async {
            print("\nJust the weather: ")
            print(weather)
            
            self.weatherDesc = weather
            
            self.tempretureLabel.text = "\(Int(round(weather.tempCelsius)))°"
            self.mainWeather.text = "\(weather.mainWeather)"
            self.determineWeatherIcon(iconID: weather.weatherIconID)
            
            self.tableView.reloadData()
            
            //Картинки плохого качества, будем юзать эмоджи
            //self.downloadImageFromServer(iconID: weather.weatherIconID)
        }
    }
    
    
    func didNotGetWeather(_ error: NSError) {
        DispatchQueue.main.async {
            print("Cant get weather")
            self.tempretureLabel.text = "Check you internet connection!°"
            self.mainWeather.text = "Could not determine the weather."
            self.determineWeatherIcon(iconID: "666")
        }
        print("didNotGetWeather error: \(error)")

    }
    
    
    // MARK: - CLLocationManagerDelegate methods
    
    // MARK: - CLLocationManagerDelegate and related methods
    
    func getLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            showSimpleAlert(
                title: "Please turn on location services",
                message: "This app needs location services in order to report the weather " +
                    "for your current location.\n" +
                "Go to Settings → Privacy → Location Services and turn location services on."
            )
            return
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus == .authorizedWhenInUse else {
            switch authStatus {
            case .denied, .restricted:
                addressLabel.text = "Location services for this app are disabled"
                let alert = UIAlertController(
                    title: "Location services for this app are disabled",
                    message: "In order to get your current location, please open Settings for this app, choose \"Location\"  and set \"Allow location access\" to \"While Using the App\".",
                    preferredStyle: .alert
                )
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) {
                    action in
                    if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                        //UIApplication.shared.openURL(url as URL)
                        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(openSettingsAction)
                present(alert, animated: true, completion: nil)
                return
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            default:
                print("Oops! Shouldn't have come this far.")
            }
            
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("\nLocation from newLocation: \n")
        print(newLocation)
        
        spinner.stopAnimating()
        spinner.isHidden = true
        
        //A negative value indicates that the location’s latitude and longitude are invalid.
        if newLocation.horizontalAccuracy < 0 {
            addressLabel.text = "Invalid coordinates"
            return
        }
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            //print("\nDistance: ")
            distance = newLocation.distance(from: location)
            locationManager.stopUpdatingLocation()
//            print(distance)
//            print("\nLoc acc: ")
//            print(location.horizontalAccuracy)
//            print("\nNewLoca: ")
//            print(newLocation.horizontalAccuracy)
        }
        
        guard distance > 0 else{
            locationManager.stopUpdatingLocation()
            return
        }

        
        
        if location == nil || distance > 5 {
            location = newLocation
            locationManager.stopUpdatingLocation()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            let myLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
            
            longitudeLabel.text = "\(myLocation.longitude)"
            latitudeLabel.text = "\(myLocation.latitude)"
            
            weatherGetter.getWeather(lon: myLocation.longitude, lat: myLocation.latitude)
            getReversedGeocodeLocation(from: newLocation)
            //updateLabels()

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error: \(error)")
        
        spinner.stopAnimating()
        spinner.isHidden = true
        
        longitudeLabel.text = "0.00"
        latitudeLabel.text = "0.00"
        addressLabel.text = "Could not determine your location"
        
        tempretureLabel.text = "666°"
        mainWeather.text = "Could not determine the weather."
        determineWeatherIcon(iconID: "666")

        locationManager.stopUpdatingLocation()
        
        DispatchQueue.main.async {
            self.location = nil
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Reverse Geocoding
    
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
                    DispatchQueue.main.async {
//                        print("\nGeocoded data: ")
//                        print(self.addressFromPlacemark)
                        //self.addressFromPlacemark = line
                        self.addressLabel.text = line
                        print("get reverse")
                        //self.updateLabels()
                    }
                }
                
            }
            else {
                print("Problem with the data received from geocoder")
            }
            
        })
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
                        self.image = UIImage(data: imageData)!
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

    //MARK: - IBActions

    @IBAction func determineWeatherBtn(_ sender: UIButton) {
        
        spinner.startAnimating()
        spinner.isHidden = false
        
        getLocation()
        //determineLocation.getLocation(locationManager: locationManager, delegate: self)
        //updateLabels()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if indexPath.row == 0{
            cell.textLabel?.text = "Date:"
            if let location = location{
                let dateFormatter = DateFormatter.localizedString(from: location.timestamp, dateStyle: .medium, timeStyle: .medium)
                cell.detailTextLabel?.text = "\(dateFormatter)"
            }else {
                cell.detailTextLabel?.text = "Could not define date."
            }
            //return cell
        }
        
        if indexPath.row == 1{
            //let cell = tableView.dequeueReusableCell(withIdentifier: "notCell", for: indexPath)
            cell.textLabel?.text = "Weather description"
            
            if let weatherDesc = weatherDesc{
                cell.detailTextLabel?.text = "\(String(weatherDesc.weatherDescription)!.uppercased())"
            }else {
                cell.detailTextLabel?.text = "Could not define it."
            }
            
            //return cell
        }
    
        if indexPath.row == 2{
            //let cell = tableView.dequeueReusableCell(withIdentifier: "notCell", for: indexPath)
            cell.textLabel?.text = "Humidity 💧"
            
            if let weatherDesc = weatherDesc{
                cell.detailTextLabel?.text = "\(weatherDesc.humidity)"
            }else {
                cell.detailTextLabel?.text = "Could not define it."
            }
            
            //return cell
        }
        if indexPath.row == 3{
            //let cell = tableView.dequeueReusableCell(withIdentifier: "notCell", for: indexPath)
            cell.textLabel?.text = "Wind speed 💨"
            
            if let weatherDesc = weatherDesc{
                cell.detailTextLabel?.text = "\(weatherDesc.windSpeed) m/s"
            }else {
                cell.detailTextLabel?.text = "Could not define it."
            }
            
            //return cell
        }
        if indexPath.row == 4{
            //let cell = tableView.dequeueReusableCell(withIdentifier: "notCell", for: indexPath)
            cell.textLabel?.text = "Clouds ☁️"
            
            if let weatherDesc = weatherDesc{
                cell.detailTextLabel?.text = "\(weatherDesc.cloudCover)%"
            }else {
                cell.detailTextLabel?.text = "Could not define it."
            }
            
            //return cell
        }
        
        return cell
    }
    
    //MARK: -
    //Не обращайте внимание, это всего лишь костыль
    
    func determineWeatherIcon(iconID: String){
        
        switch iconID {
        case "01d":
            self.iconLabel.text = "🌞"//clear sky
        case "01n":
            self.iconLabel.text = "🌚"
        case "02d":
            self.iconLabel.text = "🌤"//few clouds
        case "02n":
            self.iconLabel.text = "🌤"
        case "03d":
            self.iconLabel.text = "⛅️"//scattered clouds
        case "03n":
            self.iconLabel.text = "⛅️"
        case "04d":
            self.iconLabel.text = "☁️"//broken clouds
        case "04n":
            self.iconLabel.text = "☁️"
        case "09d":
            self.iconLabel.text = "🌧"//shower rain
        case "09n":
            self.iconLabel.text = "🌧"
        case "10d":
            self.iconLabel.text = "🌦"//rain
        case "10n":
            self.iconLabel.text = "🌦"
        case "11d":
            self.iconLabel.text = "⛈"//thunderstorm
        case "11n":
            self.iconLabel.text = "⛈"
        case "13d":
            self.iconLabel.text = "🌨"//snow
        case "13n":
            self.iconLabel.text = "🌨"
        case "50d":
            self.iconLabel.text = "🌫"//mist
        case "50n":
            self.iconLabel.text = "🌫"
            
        default:
            self.iconLabel.text = "☄️"
        }
    }
    
    // MARK: - Utility methods
    // -----------------------
    
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style:  .default, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}





