//
//  DetailHistoryViewController.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 13.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import CoreData

class DetailHistoryViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!//°
    @IBOutlet weak var humidityLabel: UILabel!//💧
    @IBOutlet weak var cloudLabel: UILabel!//☁️
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateOfReqLabel: UILabel!
    @IBOutlet weak var mWwDLabel: UILabel!
    
    var address = String()
    var clouds = Int()
    var dateOfReq = Date()
    var humidity = Int()
    var icon = String()
    var latitude = Double()
    var longitude = Double()
    var mainWeather = String()
    var tempreture = Double()
    var weatherDesc = String()
    var windSpeed = Double()
    
    let textView = UITextView()
    
    //var iconLabelText = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    fileprivate func setUpView(){
        iconLabel.text = icon
        if tempreture < 10{
            tempLabel.text = "0\(Int(tempreture))°"
        }else {
            tempLabel.text = "\(Int(tempreture))°"
        }
        humidityLabel.text = "\(humidity)%💧"
        cloudLabel.text = "\(clouds)%☁️"
        
        let currenDate = DateFormatter.localizedString(from: dateOfReq, dateStyle: .medium, timeStyle: .medium)
        dateOfReqLabel.text = "The weather for \(currenDate)."
        mWwDLabel.text = "\(mainWeather): \(weatherDesc). Wind speed today: \(windSpeed) m/s.\n"
        
        var coordinates = ""
        coordinates.add(text: String(longitude))
        coordinates.add(text: String(latitude), separatedBy: ", ")
        addressLabel.text = "Your address: \(address).\nWith coordinates: \n\(coordinates)"
    }
    
    
}
