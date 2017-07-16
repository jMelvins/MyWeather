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
    @IBOutlet weak var coordinatesLabel: UILabel!
    
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
        view.backgroundColor = UIColor(red: 168/255.0, green: 218/255.0,
                                       blue: 220/255.0, alpha: 1.0)
        
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
        //coordinatesLabel.text = "With coordinates: \n\(coordinates)"
        coordinatesLabel.text = ""
        addressLabel.text = "Your address: \(address).\nWith coordinates: \n\(coordinates)"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("DISAPPEAR")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
