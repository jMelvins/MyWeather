//
//  ViewController.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 12.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentWeatherViewController: UIViewController, CLLocationManagerDelegate, WeatherGetterDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var mainWeather: UILabel!
    
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    let locationManager = CLLocationManager()
    var location: CLLocation? = nil
    var weatherDesc: Weather?
    
    var weatherGetter: WeatherGetter!
    var determineLocation = DetermineLocation()
    
    var addressFromPlacemark = ""
    var image = UIImage()
    
    var managedObjectContext: NSManagedObjectContext?

    //Добавляем спиннер программно
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherGetter = WeatherGetter(delegate: self)
        
        tableView.backgroundColor = UIColor(red: 69/255.0, green: 123/255.0,
                                     blue: 157/255.0, alpha: 1.0)
        tableView.separatorColor = UIColor(red: 230/255.0, green: 57/255.0,
                                    blue: 70/255.0, alpha: 1.0)
        tableView.indicatorStyle = .white
        
        longitudeLabel.text = "-"
        latitudeLabel.text = "-"
        addressLabel.text = "Wait. We're trying to determine your location."
        iconLabel.text = "☄️"
        tempretureLabel.text = "--°"
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
//            print("\nJust the weather: ")
//            print(weather)
            
            self.weatherDesc = weather
            
            self.tempretureLabel.text = "\(Int(round(weather.tempCelsius)))°"
            self.mainWeather.text = "\(weather.mainWeather)"
            self.iconLabel.text = self.determineWeatherIcon(iconID: weather.weatherIconID)
            //self.determineWeatherIcon(iconID: weather.weatherIconID)
            
            self.tableView.reloadData()
            
            //Картинки плохого качества, будем юзать эмоджи
            //self.downloadImageFromServer(iconID: weather.weatherIconID)
        }
        
        //Так как все данный получены - сохраняем в CoreData
        //Делаем это через 1 секунду, т.к. реверс геокодиг работает долго
        afterDelay(1, closure: {
            self.savingDataInCoreData()
        })
    }
    
    
    func didNotGetWeather(_ error: NSError) {
        DispatchQueue.main.async {
            print("Cant get weather")
            self.tempretureLabel.text = "Check you internet connection!"
            self.mainWeather.text = "Could not determine the weather."
            self.iconLabel.text = self.determineWeatherIcon(iconID: "666")
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
//        print("\nLocation from newLocation: \n")
//        print(newLocation)
//        
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
            
            //let myLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
            coordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
            
            longitudeLabel.text = "\(coordinate.longitude)"
            latitudeLabel.text = "\(coordinate.latitude)"
            
            weatherGetter.getWeather(lon: coordinate.longitude, lat: coordinate.latitude)
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
        addressLabel.text = "Could not define your location."
        
        tempretureLabel.text = "666°"
        mainWeather.text = "Could not determine the weather."
        iconLabel.text = determineWeatherIcon(iconID: "666")

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
                        self.addressFromPlacemark = line
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
    
    //MARK: - IBActions
    @IBAction func determineWeatherBtn(_ sender: UIButton) {
        
        spinner.startAnimating()
        spinner.isHidden = false
        
        getLocation()
        
        //savingDataInCoreData()
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
            
        }
        
        if indexPath.row == 1{
            //let cell = tableView.dequeueReusableCell(withIdentifier: "notCell", for: indexPath)
            cell.textLabel?.text = "Weather description"
            
            if let weatherDesc = weatherDesc{
                cell.detailTextLabel?.text = "\(String(weatherDesc.weatherDescription)!.uppercased())"
            }else {
                cell.detailTextLabel?.text = "Could not define it."
            }
            
        }
    
        if indexPath.row == 2{
            //let cell = tableView.dequeueReusableCell(withIdentifier: "notCell", for: indexPath)
            cell.textLabel?.text = "Humidity 💧"
            
            if let weatherDesc = weatherDesc{
                cell.detailTextLabel?.text = "\(weatherDesc.humidity)%"
            }else {
                cell.detailTextLabel?.text = "Could not define it."
            }
        }
        if indexPath.row == 3{
            //let cell = tableView.dequeueReusableCell(withIdentifier: "notCell", for: indexPath)
            cell.textLabel?.text = "Wind speed 💨"
            
            if let weatherDesc = weatherDesc{
                cell.detailTextLabel?.text = "\(weatherDesc.windSpeed) m/s"
            }else {
                cell.detailTextLabel?.text = "Could not define it."
            }
            
        }
        if indexPath.row == 4{
            //let cell = tableView.dequeueReusableCell(withIdentifier: "notCell", for: indexPath)
            cell.textLabel?.text = "Clouds ☁️"
            
            if let weatherDesc = weatherDesc{
                cell.detailTextLabel?.text = "\(weatherDesc.cloudCover)%"
            }else {
                cell.detailTextLabel?.text = "Could not define it."
            }
            
        }        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColor(red: 69/255.0, green: 123/255.0,
                                               blue: 157/255.0, alpha: 1.0)
        
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor(red: 241/255.0, green: 250/255.0,
                                          blue: 238/255.0, alpha: 1.0)
            textLabel.highlightedTextColor = textLabel.textColor
        }
        if let detailLabel = cell.detailTextLabel{
            detailLabel.textColor = UIColor(red: 241/255.0, green: 250/255.0,
                                          blue: 238/255.0, alpha: 1.0)
            detailLabel.highlightedTextColor = detailLabel.textColor
        }
        
    }
    
    //MARK: -
    //Не обращайте внимание, это всего лишь костыль
    
    func determineWeatherIcon(iconID: String) -> String{
        
        switch iconID {
        case "01d":
            //self.iconLabel.text = "🌞"//clear sky
            return "🌞"
        case "01n":
            //self.iconLabel.text = "🌚"
            return "🌚"
        case "02d":
            //self.iconLabel.text = "🌤"//few clouds
            return "🌤"
        case "02n":
            //self.iconLabel.text = "🌤"
            return "🌤"
        case "03d":
            //self.iconLabel.text = "⛅️"//scattered clouds
            return "⛅️"
        case "03n":
            //self.iconLabel.text = "⛅️"
            return "⛅️"
        case "04d":
            //self.iconLabel.text = "☁️"//broken clouds
            return "☁️"
        case "04n":
            self.iconLabel.text = "☁️"
            return "☁️"
        case "09d":
            //self.iconLabel.text = "🌧"//shower rain
            return "🌧"
        case "09n":
            //self.iconLabel.text = "🌧"
            return "🌧"
        case "10d":
            //self.iconLabel.text = "🌦"//rain
            return "🌦"
        case "10n":
            //self.iconLabel.text = "🌦"
            return "🌦"
        case "11d":
            //self.iconLabel.text = "⛈"//thunderstorm
            return "⛈"
        case "11n":
            //self.iconLabel.text = "⛈"
            return "⛈"
        case "13d":
            //self.iconLabel.text = "🌨"//snow
            return "🌨"
        case "13n":
            //self.iconLabel.text = "🌨"
            return "🌨"
        case "50d":
            //self.iconLabel.text = "🌫"//mist
            return "🌫"
        case "50n":
            //self.iconLabel.text = "🌫"
            return "🌫"
            
        default:
            //self.iconLabel.text = "☄️"
            return "☄️"
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
    
    // MARK: - CoreData
    
    func savingDataInCoreData(){
        
        //let weatherRequest: WeatherRequest
        let weatherRequest = WeatherRequest(context: managedObjectContext!)
        //let iconID = determineWeatherIcon(iconID: (weatherDesc?.weatherIconID)!)
        
        weatherRequest.address = addressFromPlacemark
        weatherRequest.latitude = coordinate.latitude
        weatherRequest.longitude = coordinate.longitude
        weatherRequest.dateOfReq = location?.timestamp as NSDate?
        weatherRequest.icon = determineWeatherIcon(iconID: (weatherDesc?.weatherIconID)!)
        weatherRequest.tempreture = round((weatherDesc?.tempCelsius)!)
        weatherRequest.mainWeather = weatherDesc?.mainWeather
        weatherRequest.weatherDesc = weatherDesc?.weatherDescription
        weatherRequest.humidity = (weatherDesc?.humidity)!
        weatherRequest.windSpeed = (weatherDesc?.windSpeed)!
        weatherRequest.clouds = (weatherDesc?.cloudCover)!
        
//        print("Saving data")
//        print(weatherRequest.address!)
//        print(weatherRequest.icon!)
        
        do {
            try managedObjectContext?.save()
        } catch  {
            print("Core Data Error:")
            fatalCoreDataError(error)
        }
    }
    
}





