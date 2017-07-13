//
//  Functions.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 13.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import Foundation

//поиск папки с DataMpdel
let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(
    rawValue: "MyManagedObjectContextSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}


func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    
    //Take a good look at afterDelay()’s second parameter, the one named closure. Its type is () -> (). That’s not some weird emoticon; it is Swift notation for a parameter that takes a closure with no arguments and no return value.
    
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
    
}
