//
//  HistoryViewController.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 13.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!    
    
    lazy var fetchedResultsController:
        NSFetchedResultsController<WeatherRequest> = {
            let fetchRequest = NSFetchRequest<WeatherRequest>()
            let entity = WeatherRequest.entity()
            fetchRequest.entity = entity
            let sortDescriptor = NSSortDescriptor(key: "dateOfReq", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchBatchSize = 20
            let fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: self.managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: "weatherRequest")
            
            fetchedResultsController.delegate = self
            return fetchedResultsController
    }()
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    var backgroundImage = UIImageView(image: #imageLiteral(resourceName: "forest"))
    var lightBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBlurEffect()
        setUpTableView()

        //Загружаем данные из кор дата сразу же после загрузки вью
        performFetch()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    fileprivate func addBlurEffect(){
        let blurView = UIVisualEffectView(effect: lightBlurEffect)
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        blurView.frame = backgroundImage.bounds
        backgroundImage.addSubview(blurView)

    }
    
    fileprivate func setUpTableView(){
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = backgroundImage
        tableView.separatorColor = UIColor(red: 230/255.0, green: 57/255.0,
                                           blue: 70/255.0, alpha: 1.0)
        tableView.indicatorStyle = .white
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    // MARK: -
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! CustomCell
       
        let history = fetchedResultsController.object(at: indexPath) 
        //Т.к ячейка кастомная, можно вынести методы по ее заполнению в отдельный класс
        cell.configure(for: history)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,forRowAt indexPath: IndexPath) {
        
        //контекст удаляет элемент по адресу ячейки, затем NSFetchedResultsChangeDelete это чекает и уже выполняет свои методы, описанный в extension
        if editingStyle == .delete {
            let history = fetchedResultsController.object(at: indexPath)
            managedObjectContext.delete(history)
            print(indexPath)
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Передаем все имеющиеся данные в DetailHistoryVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DeckSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailHistoryViewController
                let toSend = fetchedResultsController.object(at: indexPath)
                controller.icon = toSend.icon!
                controller.address = toSend.address!
                controller.tempreture = toSend.tempreture
                controller.humidity = toSend.humidity
                controller.clouds = toSend.clouds
                controller.mainWeather = toSend.mainWeather!
                controller.weatherDesc = toSend.weatherDesc!
                controller.windSpeed = toSend.windSpeed
                controller.dateOfReq = toSend.dateOfReq! as Date
                controller.longitude = toSend.longitude
                controller.latitude = toSend.latitude
            }
        }
    }

}


//Описание слушателя кор даты. Реагирует на любые изменения в ней, следовательно перересовывает tableView
extension HistoryViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!)
                as? CustomCell {
                let history = controller.object(at: indexPath!) as! WeatherRequest
                cell.configure(for: history)
            }
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        } }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
