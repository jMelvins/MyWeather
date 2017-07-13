//
//  AppDelegate.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 12.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print(applicationDocumentsDirectory)
        
        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            let currentWeatherViewController = tabBarViewControllers[0]
                as! CurrentWeatherViewController
            currentWeatherViewController.managedObjectContext = managedObjectContext

        }
        
        //UILabel.appearance().font = UIFont(name: "Courier New", size: 120.0)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyWeather")
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    
    func listenForFatalCoreDataNotifications() {
        // 1
        NotificationCenter.default.addObserver(
            forName: MyManagedObjectContextSaveDidFailNotification,
            object: nil, queue: OperationQueue.main, using: { notification in
                // 2
                let alert = UIAlertController(
                    title: "Internal Error",
                    message:
                    "There was a fatal error in the app and it cannot continue.\n\n"
                        + "Press OK to terminate the app. Sorry for the inconvenience.",
                    preferredStyle: .alert)
                // 3
                let action = UIAlertAction(title: "OK", style: .default) { _ in
                    let exception = NSException(
                        name: NSExceptionName.internalInconsistencyException,
                        reason: "Fatal Core Data error", userInfo: nil)
                    exception.raise()
                }
                alert.addAction(action)
                // 4
                self.viewControllerForShowingAlert().present(alert, animated: true,completion: nil)
        }) }
    // 5
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController =
            rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
}

