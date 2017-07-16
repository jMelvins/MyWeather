//
//  CustomCell.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 13.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        backgroundColor = UIColor(red: 69/255.0, green: 123/255.0,
//                                         blue: 157/255.0, alpha: 1.0)
        backgroundColor = UIColor.clear
        
//        tempLabel.textColor = UIColor(red: 241/255.0, green: 250/255.0,
//                                            blue: 238/255.0, alpha: 1.0)
//        addressLabel.textColor = UIColor(red: 241/255.0, green: 250/255.0,
//                                            blue: 238/255.0, alpha: 1.0)
//        latitudeLabel.textColor = UIColor(red: 241/255.0, green: 250/255.0,
//                                            blue: 238/255.0, alpha: 1.0)
//        longitudeLabel.textColor = UIColor(red: 241/255.0, green: 250/255.0,
//                                            blue: 238/255.0, alpha: 1.0)
//        dateLabel.textColor = UIColor(red: 168/255.0, green: 218/255.0,
//                                                 blue: 220/255.0, alpha: 1.0)
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(red: 0/255.0, green: 155/255.0,
                                                blue: 255/255.0, alpha: 0.2)
        selectedBackgroundView = selectionView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configure(for weather: WeatherRequest) {
        
        if (weather.address?.isEmpty)! {
            addressLabel.text = "No Description"
        } else {
            addressLabel.text = weather.address!
        }
        let currenDate = DateFormatter.localizedString(from: weather.dateOfReq! as Date, dateStyle: .medium, timeStyle: .medium)
        
        addressLabel.text = weather.address
        dateLabel.text = currenDate
        iconLabel.text = weather.icon!
        latitudeLabel.text = "Latitude: \(weather.latitude)"
        longitudeLabel.text = "Longitude: \(weather.longitude)"
        //cell.tempLabel.text = "\(Int(weather.tempreture))°"
        
    }

}
