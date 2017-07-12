//
//  String+AddText.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 12.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import Foundation


extension String{

    mutating func add(text: String?, separatedBy separator: String = "") {
        
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
