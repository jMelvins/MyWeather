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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var mainWeather: UILabel!
    
    //Храним данные для передачи в CoreData
    let locationManager = CLLocationManager()
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var weatherDesc: Weather?
    var managedObjectContext: NSManagedObjectContext?
    
    //Хранит в себе прошлые запросы в CLLocation
    var location: CLLocation? = nil
    
    var weatherGetter: WeatherGetter!
    
    var addressFromPlacemark = ""
    var wasFound = false
    
    //Добавляем спиннер программно
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherGetter = WeatherGetter(delegate: self)
        
        setUpView()
        
        //Начинаем искать сразуже при входе
        getLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    fileprivate func setUpView(){
        //Красим tableView
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor(red: 230/255.0, green: 57/255.0,
                                           blue: 70/255.0, alpha: 1.0)
        tableView.indicatorStyle = .white
        
        //Задаем дефолтные значения
        longitudeLabel.text = "-"
        latitudeLabel.text = "-"
        addressLabel.text = "Wait. We're trying to determine your location."
        iconLabel.text = "☄️"
        tempretureLabel.text = "--°"
        mainWeather.text = ""
        
        //Добвляем спиннер
        if view.viewWithTag(1000) == nil {
            spinner.center = addressLabel.center
            spinner.center.y += spinner.bounds.size.height/2 + 20
            spinner.startAnimating()
            spinner.tag = 1000
            view.addSubview(spinner)
        }
    }
    
    // MARK: - WeatherGetterDelegate
    
    func didGetWeather(_ weather: Weather) {
        DispatchQueue.main.async {
            
            self.weatherDesc = weather
            self.wasFound = true
            
            self.tempretureLabel.text = "\(Int(round(weather.tempCelsius)))°"
            self.mainWeather.text = "\(weather.mainWeather)"
            self.iconLabel.text = self.determineWeatherIcon(iconID: weather.weatherIconID)
            
            self.tableView.reloadData()
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
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
            self.tempretureLabel.text = "Check you internet connection!"
            self.mainWeather.text = "Could not determine the weather."
            self.iconLabel.text = self.determineWeatherIcon(iconID: "666")
            self.addressLabel.text = "It's impossible to detirmine address without the Interner."
            self.wasFound = false
        }
        print("didNotGetWeather error: \(error)")

    }
    
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
                spinner.stopAnimating()
                spinner.isHidden = true
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
                spinner.stopAnimating()
                spinner.isHidden = true
                addressLabel.text = "Location services for this app are disabled"
                locationManager.requestWhenInUseAuthorization()
                
            default:
                spinner.stopAnimating()
                spinner.isHidden = true
                print("Oops! Shouldn't have come this far.")
            }
            
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestLocation()
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        
        spinner.stopAnimating()
        spinner.isHidden = true
        
        //A negative value indicates that the location’s latitude and longitude are invalid.
        if newLocation.horizontalAccuracy < 0 {
            addressLabel.text = "Invalid coordinates"
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            //Считаем дистанцию между прошлым запросом и нынешним
            distance = newLocation.distance(from: location)
        }
        
        //Если следующий запрос близок к прошлому, то ничего не делаем
        //1000 потому что аккуратность с которой ищет LocationManager = 1km
        if location != nil && distance < 1000 && wasFound{
            return
        }
        
        if location == nil || distance >= 0 {
            location = newLocation
            locationManager.stopUpdatingLocation()
            
            //Если location получило/обновило значение, то обновляем tableView
            //т.к. первая ячейка - ячейка даты полученной именно из CLLocation
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            coordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
            
            longitudeLabel.text = String(format: "%0.8f", coordinate.longitude)
            latitudeLabel.text = String(format: "%0.8f", coordinate.latitude)
            addressLabel.text = "Wait. We're trying to determine your location."
            
            weatherGetter.getWeather(lon: coordinate.longitude, lat: coordinate.latitude)
            getReversedGeocodeLocation(from: newLocation)
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

        DispatchQueue.main.async {
            self.wasFound = false
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
                    
                    //Обновляем данные
                    DispatchQueue.main.async {
                        self.addressFromPlacemark = line
                        self.addressLabel.text = line
                        print("get reverse")
                    }
                }
            }
            else {
                print("Problem with the data received from geocoder")
            }
            
        })
        spinner.stopAnimating()
        spinner.isHidden = true
    }
    
    //MARK: - IBActions
    @IBAction func determineWeatherBtn(_ sender: UIButton) {
        
        spinner.startAnimating()
        spinner.isHidden = false
        
        getLocation()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard wasFound else {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Date:"
                cell.detailTextLabel?.text = "Could not define date."
            case 1:
                cell.textLabel?.text = "Weather description"
                cell.detailTextLabel?.text = "Could not define it."
            case 2:
                cell.textLabel?.text = "Humidity 💧"
                cell.detailTextLabel?.text = "Could not define it."
            case 3:
                cell.textLabel?.text = "Wind speed 💨"
                cell.detailTextLabel?.text = "Could not define it."
            case 4:
                cell.textLabel?.text = "Clouds ☁️"
                cell.detailTextLabel?.text = "Could not define it."
            default:
                return cell
            }
            
            return cell
        }
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Date:"
            let dateFormatter = DateFormatter.localizedString(from: (location?.timestamp)!, dateStyle: .medium, timeStyle: .medium)
            cell.detailTextLabel?.text = "\(dateFormatter)"
        case 1:
            cell.textLabel?.text = "Weather description"
            cell.detailTextLabel?.text = "\(String((weatherDesc?.weatherDescription)!)!.uppercased())"
        case 2:
            cell.textLabel?.text = "Humidity 💧"
            cell.detailTextLabel?.text = "\(weatherDesc!.humidity)%"
        case 3:
            cell.textLabel?.text = "Wind speed 💨"
            cell.detailTextLabel?.text = "\(weatherDesc!.windSpeed) m/s"
        case 4:
            cell.textLabel?.text = "Clouds ☁️"
            cell.detailTextLabel?.text = "\(weatherDesc!.cloudCover)%"
        default:
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //cell.backgroundColor = UIColor(red: 69/255.0, green: 123/255.0, blue: 157/255.0, alpha: 1.0)
        cell.backgroundColor = UIColor.clear
        
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
        
        do {
            try managedObjectContext?.save()
        } catch  {
            print("Core Data Error:")
            fatalCoreDataError(error)
        }
    }
    
}





