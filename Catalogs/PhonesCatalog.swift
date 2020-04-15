//
//  PhonesCatalog.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 02.12.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class PhonesCatalog:  UITableViewController, NSFetchedResultsControllerDelegate {

    var firm: Firms!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!

    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showPhoneDetails", sender: nil)
    }
    
    @IBOutlet weak var firmLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFirm()
        featchPhonesFromCD()
        addGestures()
        setNotification()
    }
    
    func setNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appIsActive), name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    
    @objc func appIsActive() {
        tableView.reloadData()
    }
    
    func setFirm() {
        if let tbc = self.tabBarController as? PhoneTabBarController {
            self.firm = tbc.modelPhone.firm
            if let firm = self.firm {
                self.firmLable.text = firm.name! + "(" + firm.edrpou! + ")"
            }
        }
    }
    
    func featchPhonesFromCD() {
        if let firm = self.firm {
            let predicate = NSPredicate(format: "phoneFirm = %@",  firm)
            fetchedResultsController = CoreDataManager.instance.fetchedResultsController(entityName: "Phones", keyForSort: "name", predicate: predicate)
            do {
                try fetchedResultsController.performFetch()
                 } catch {
                print(error)
            }
            tableView.reloadData()
        }
    }
    
    func addGestures() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(imageTapped))
        lpgr.minimumPressDuration = 2.0
        lpgr.delaysTouchesBegan = true
        tableView.addGestureRecognizer(lpgr)
        /*
        let tapGestureRecognize = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGestureRecognize.numberOfTapsRequired = 2
        tapGestureRecognize.delegate = self as? UIGestureRecognizerDelegate
        tableView.addGestureRecognizer(tapGestureRecognize)
         */
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        let tappoint = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: tappoint) {
            let phone = fetchedResultsController.object(at: indexPath) as! Phones
            self.callPhone(phoneNumber: phone.phone!)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoneDetails" {
            let controller = segue.destination as! PhoneDetails
            controller.firm = self.firm
            if sender != nil {
                let phone = sender as! Phones
                controller.phone = phone
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let phone = fetchedResultsController.object(at: indexPath) as! Phones
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = phone.name
        if !(phone.person?.isEmpty)! {
            cell.textLabel?.text = (cell.textLabel?.text)! + "(" + phone.person! + ")"
        }
        cell.detailTextLabel?.text = phone.phone
   //     cell.imageView?.image = UIImage(named: "icons8-громкость-звонка-30")
        let existContact = fetcthExistContacts(phoneCD : phone)
        if existContact.count > 0 {
            cell.textLabel?.textColor = .red
            cell.detailTextLabel?.textColor = .red
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let phone = fetchedResultsController.object(at: indexPath) as! Phones
       performSegue(withIdentifier: "showPhoneDetails", sender: phone)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        featchPhonesFromCD()
    }
    
    func deletePhone(indexPath: IndexPath) {
        let managedObject = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
        CoreDataManager.instance.managedObjectContext.delete(managedObject)
        CoreDataManager.instance.saveContext()
        featchPhonesFromCD()
    }

     
    
    override public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualToggleAlltAction(forRowAtIndexPath: indexPath, title: "Вилучити", image: UIImage(named: "icons8-удалить-22")!, сolor: UIColor.white, backgroundColor: UIColor.red, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.deletePhone(indexPath: indexPath)
            success(true)
        })
        let editAction = self.contextualToggleAlltAction(forRowAtIndexPath: indexPath, title: "Змінити", image: UIImage(named: "icon edit pencil")!, сolor: UIColor.white, backgroundColor: UIColor.darkGray, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let phone = self.fetchedResultsController.object(at: indexPath) as! Phones
            self.performSegue(withIdentifier: "showPhoneDetails", sender: phone)
            success(true)
        })
        
        let addAction = self.contextualToggleAlltAction(forRowAtIndexPath: indexPath, title: "Додати", image: UIImage(named: "icons8-добавить-23")!, сolor: UIColor.white, backgroundColor: UIColor.brown, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.performSegue(withIdentifier: "showPhoneDetails", sender: nil)
            success(true)
        })
        
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [deleteAction,editAction,addAction])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }
    
    
    override public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
             let callAction = self.contextualToggleAlltAction(forRowAtIndexPath: indexPath, title: "Викликати", image: UIImage(named: "icons8-громкость-звонка-30")!, сolor: UIColor.white, backgroundColor: UIColor.blue, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                let phone = self.fetchedResultsController.object(at: indexPath) as! Phones
                if let phoneNumber = phone.phone {
                    self.callPhone(phoneNumber: phoneNumber)
                }
                success(true)
              })
            let saveContactsAction = self.contextualToggleAlltAction(forRowAtIndexPath: indexPath, title: "Додати конт.", image: UIImage(named: "icons8-контакты-30")!, сolor: UIColor.white, backgroundColor: UIColor.blue, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                let phone = self.fetchedResultsController.object(at: indexPath) as! Phones
                self.createContact(phoneCD: phone)
                self.tableView.reloadData()
                success(true)
            })

            let swipeActionConfig = UISwipeActionsConfiguration(actions: [callAction,saveContactsAction])
            swipeActionConfig.performsFirstActionWithFullSwipe = false
            return swipeActionConfig
    }
    
    

}

