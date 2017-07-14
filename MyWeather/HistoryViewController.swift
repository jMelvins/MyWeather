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

    var weatherRequest = [WeatherRequest]()
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(red: 69/255.0, green: 123/255.0,
                                            blue: 157/255.0, alpha: 1.0)
        tableView.separatorColor = UIColor(red: 230/255.0, green: 57/255.0,
                                           blue: 70/255.0, alpha: 1.0)
        tableView.indicatorStyle = .white

        performFetch()
        
        //добавляет кнопку редактирования справа сверху
        navigationItem.rightBarButtonItem = editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        //Выдает неправильные значение если запущен дебаг. Если просто открыть приложение, обновляет все как надо
        //Выдавало не те значения из за того что мы неправильно изменяли кор дату
//        print("\n eto \n")
//        print(sectionInfo.numberOfObjects)
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! CustomCell
        
        let history = fetchedResultsController.object(at: indexPath)
        weatherRequest.append(history)
        
        cell.configure(for: history)
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,forRowAt indexPath: IndexPath) {
        
        //контекст удаляет элемент по адресу ячейки, затем NSFetchedResultsChangeDelete это чекает и уже выполняет свои методы, описанный в extension
        if editingStyle == .delete {
            let history = fetchedResultsController.object(at: indexPath)
            managedObjectContext.delete(history)
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DeckSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailHistoryViewController
                let toSend = weatherRequest[indexPath.row]
                controller.icon = toSend.icon!
                controller.address = toSend.address!
                controller.tempreture = toSend.tempreture
                controller.humidity = toSend.humidity
                controller.clouds = toSend.clouds
            }
        }
    }

}


extension HistoryViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
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
                let location = controller.object(at: indexPath!) as! WeatherRequest
                cell.configure(for: location)
            }
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        } }
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
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
