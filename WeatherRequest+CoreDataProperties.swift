//
//  WeatherRequest+CoreDataProperties.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 13.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import Foundation
import CoreData


extension WeatherRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherRequest> {
        return NSFetchRequest<WeatherRequest>(entityName: "WeatherRequest")
    }

    @NSManaged public var address: String?
    @NSManaged public var clouds: Int
    @NSManaged public var dateOfReq: Date?
    @NSManaged public var humidity: Int
    @NSManaged public var icon: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var mainWeather: String?
    @NSManaged public var tempreture: Double
    @NSManaged public var weatherDesc: String?
    @NSManaged public var windSpeed: Double

}
