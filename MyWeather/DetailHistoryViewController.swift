//
//  DetailHistoryViewController.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 13.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import CoreData

class DetailHistoryViewController: UIViewController {
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!//°
    @IBOutlet weak var humidityLabel: UILabel!//💧
    @IBOutlet weak var cloudLabel: UILabel!//☁️
    
    var address = String()
    var clouds = Int()
    var dateOfReq = NSDate()
    var humidity = Int()
    var icon = String()
    var latitude = Double()
    var longitude = Double()
    var mainWeather = String()
    var tempreture = Double()
    var weatherDesc = String()
    var windSpeed = Double()
    
    //var iconLabelText = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\n INIT DETAIL \n address: \(address) \n \(latitude)")
        
        iconLabel.text = icon
        if tempreture < 10{
            tempLabel.text = "0\(Int(tempreture))°"
        }else {
            tempLabel.text = "\(Int(tempreture))°"
        }
        humidityLabel.text = "\(humidity)%💧"
        cloudLabel.text = "\(clouds)%☁️"
        // Do any additional setup after loading the view.
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
