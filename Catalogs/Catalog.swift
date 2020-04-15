//
//  Catalog.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 23.10.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation
import UIKit
import CoreData
/*
extension UIViewController: SWRevealViewControllerDelegate {
    
    func setupMenuGestureRecognizer() {
        
        revealViewController().delegate = self
        revealViewController().frontViewController.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        revealViewController().frontViewController.view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    }
    
    //MARK: - SWRevealViewControllerDelegate
    public func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        let tagId = 112151
        if revealController.frontViewPosition == FrontViewPosition.right {
            let lock = self.view.viewWithTag(tagId)
            UIView.animate(withDuration: 0.25, animations: {
                lock?.alpha = 0
            }, completion: {(finished: Bool) in
                lock?.removeFromSuperview()
            }
            )
            lock?.removeFromSuperview()
        } else if revealController.frontViewPosition == FrontViewPosition.left {
            let lock = UIView(frame:  self.view.bounds)
            lock.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            lock.tag = tagId
            lock.alpha = 0
            lock.backgroundColor = UIColor.black
            lock.addGestureRecognizer(UITapGestureRecognizer(target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:))))
            self.view.addSubview(lock)
            UIView.animate(withDuration: 0.75, animations: {
                lock.alpha = 0.333
            }
            )
        }
    }
    
}
 */

class Catalog<Typecatalog> : UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate{
    
    typealias Select = (Typecatalog?) -> ()
    var didSelect: Select?
    
    public var unit: Typecatalog?
    var indexPathSelect: IndexPath?
    
    var entityName: String?
    var fieldForSort: String?
    var fieldForSearch : String?
    var fieldFavourite: String?
    var segueAddEdit: String?
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var searchController: UISearchController!
    var searchFooter: SearchFooter!
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //       self.selectedScope = selectedScope
        filterContent(searchText: searchBar.text!, selectedScope: searchBar.selectedScopeButtonIndex)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //       self.selectedScope = 0
        searchBar.selectedScopeButtonIndex = 0
        filterContent(searchText: searchBar.text!, selectedScope: searchBar.selectedScopeButtonIndex)
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        filterContent(searchText: searchText!, selectedScope: searchController.searchBar.selectedScopeButtonIndex)
    }
    
    func filterContent(searchText: String, selectedScope: Int) {
        var filteredImemsCount: Int = 0
        var totalItemCount: Int = 0
        
        if searchText != "" {
            let predicate = selectedScope == 0 ? NSPredicate(format: "\(self.fieldForSearch!) CONTAINS[cd] %@", searchText) :
                NSPredicate(format: "\(self.fieldForSearch!) CONTAINS[cd] %@ && \(self.fieldFavourite!) = %@", searchText, "1")
            fetchedResultsController = CoreDataManager.instance.fetchedResultsController(entityName: self.entityName!, keyForSort: self.fieldForSort!, predicate: predicate)
            fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        } else {
            let predicate = selectedScope == 0 ? nil : NSPredicate(format: "\(self.fieldFavourite!) = %@",  "1")
            fetchedResultsController = CoreDataManager.instance.fetchedResultsController(entityName: self.entityName!, keyForSort: self.fieldForSort!, predicate: predicate)
            fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        }
        do {
            try fetchedResultsController.performFetch()
            filteredImemsCount = fetchedResultsController.sections![0].numberOfObjects
            if searchText != "" {
                let predicate = selectedScope == 0 ? nil : NSPredicate(format: "\(self.fieldFavourite!) = %@",  "1")
                let fetchedResultsControllerTotal = CoreDataManager.instance.fetchedResultsController(entityName: self.entityName!, keyForSort: self.fieldForSort!, predicate: predicate)
                do {
                    try fetchedResultsControllerTotal.performFetch()
                    totalItemCount = fetchedResultsControllerTotal.sections![0].numberOfObjects
                }
                catch{
                    print(error)
                    
                }
            } else {
                totalItemCount = filteredImemsCount
            }
        } catch {
            print(error)
        }
        indexPathSelect = nil
        self.searchFooter.setIsFilteringToShow(filteredItemCount: filteredImemsCount, of: totalItemCount)
        tableView.reloadData()
        
    }
    
    @IBAction func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func choiceTapped(_ sender: Any) {
        if let indexPath = indexPathSelect {
            let unit = fetchedResultsController.object(at: indexPath) as? Typecatalog
            
            if searchController.isActive {
                searchController.isActive = false
            }
            
            if let dSelect = self.didSelect {
                dSelect(unit)
                dismiss(animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Помилка перевіркм", message: "Виберіть рядок таблиці!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func editTapped(_ sender: Any) {
        if indexPathSelect != nil {
            let unit = fetchedResultsController.object(at: indexPathSelect!) as? Typecatalog
            performSegue(withIdentifier: self.segueAddEdit!, sender: unit)
        } else {
            let alert = UIAlertController(title: "Помилка перевіркм", message: "Виберіть рядок таблиці!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addTapped(_ sender: Any) {
        if searchController.isActive {
            searchController.isActive = false
        }
        performSegue(withIdentifier: self.segueAddEdit!, sender: nil)
    }
    
    
    @IBAction func choiceButtonTypped(_ sender: Any) {
        choiceTapped(sender)
    }
    
    @IBOutlet weak var OpenSideout: UIBarButtonItem!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataFromCoreData()
        setParametresSearchController()
        addGestureTableCell()
    }
    
    public func setParametresSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Пошук..."
        searchController.searchBar.scopeButtonTitles = ["Всі", "Обране"]
   //     searchController.searchBar.showsScopeBar = false
        searchController.searchBar.delegate = self
        //    searchController.searchBar.tintColor = .candyGreen
        if #available(iOS 13.0, *) {
                   searchController.automaticallyShowsScopeBar = true
                   self.navigationItem.hidesSearchBarWhenScrolling = false
                   self.navigationItem.searchController = searchController
        } else {
            searchController.searchBar.showsScopeBar = true
            tableView.tableHeaderView = searchController.searchBar
        }
        searchFooter = SearchFooter(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        //      searchFooter.searchBackgroundColor = .candyGreen
        tableView.tableFooterView = searchFooter
        //        definesPresentationContext = false
        
    }
    
    public func addGestureTableCell() {
        if self.didSelect != nil {
            //      OpenSideout.image = UIImage(named: "icons8-отмена-22")
            //      OpenSideout.target = self
            //      OpenSideout.action = #selector(unitChoiceCatalog.cancelTapped)
            let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            tap.numberOfTapsRequired = 2
            tableView.addGestureRecognizer(tap)
        } else {
            self.navigationItem.rightBarButtonItems?.remove(at: 0)
            //        setupMenuGestureRecognizer()
            //       OpenSideout.target = self.revealViewController()
            //       OpenSideout.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 2.0
        lpgr.delaysTouchesBegan = true
        tableView.addGestureRecognizer(lpgr)
    }
    
    public func fetchDataFromCoreData() {
        fetchedResultsController = CoreDataManager.instance.fetchedResultsController(entityName: self.entityName!, keyForSort: self.fieldForSort!, predicate: nil)
        fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }

    /*
    public override func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        if searchController.isActive {
            if revealController.frontViewPosition == FrontViewPosition.right {
                self.searchController.searchBar.isUserInteractionEnabled = true
            } else if revealController.frontViewPosition == FrontViewPosition.left {
                self.searchController.searchBar.isUserInteractionEnabled = false
            }
        }
        if revealController.frontViewPosition == FrontViewPosition.right {
            self.tableView.isUserInteractionEnabled = true
        } else if revealController.frontViewPosition == FrontViewPosition.left {
            self.tableView.isUserInteractionEnabled = false
        }
        
        super.revealController(revealController, willMoveTo: position)
    }
 */
    
    @objc func handleLongPress(sender: UITapGestureRecognizer) {
        let tappoint = sender.location(in: tableView)
        if (sender.state == UIGestureRecognizer.State.ended) {
                if let indexPath = tableView.indexPathForRow(at: tappoint) {
                    indexPathSelect = indexPath
                    editTapped(0)
                }
        }
    }
    
    @objc func doubleTapped(sender: UITapGestureRecognizer) {
        let tappoint = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: tappoint) {
            indexPathSelect = indexPath
            choiceTapped(0)
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let unit = fetchedResultsController.object(at: indexPath) as! Typecatalog
        let cell = UITableViewCell()
        fillCell(cell: cell, unit: unit)
        return cell
    }
    
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    /*   override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if segue.identifier == "unitsCatalogToUnit" {
     let controller = segue.destination as! UnitsAddAndEdit
     controller.unit = sender as? UnitCD
     }
     }
     */
    
    public func fillCell(cell: UITableViewCell, unit: Typecatalog) {
        /*        if unit.favourite {
         cell.textLabel?.textColor = .magenta
         }
         cell.textLabel?.text = unit.fullname
         */
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert :
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
                indexPathSelect = indexPath
            }
        case .update:
            if let indexPath = indexPath {
                let unit = fetchedResultsController.object(at: indexPath) as! Typecatalog
                let cell = tableView.cellForRow(at: indexPath)
                fillCell(cell: cell!, unit: unit)
                indexPathSelect = indexPath
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                indexPathSelect = nil
            }
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateSearchResults(for: self.searchController)
    }
    
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPathSelect = indexPath
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        if indexPathSelect != nil {
            tableView.selectRow(at: indexPathSelect!, animated: true, scrollPosition: .middle)
        }
    }
    
    public func isFavourite(unit: Typecatalog) -> Bool {
        return false
    }
    
    func deleteunit(forRowAtIndexPath indexPath: IndexPath)  {
        let alert = UIAlertController(title: "Вилучення елемента довідника", message: "Вилучити?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler:{  (UIAlertAction) -> Void in
            self.deleteAlertAction(indexPath: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func deleteAlertAction(indexPath: IndexPath) {
        let managedObject = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
        CoreDataManager.instance.managedObjectContext.delete(managedObject)
        CoreDataManager.instance.saveContext()

    }
    
    override public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        self.indexPathSelect = indexPath
        let deleteAction = self.contextualToggleAlltAction(forRowAtIndexPath: indexPath, title: "Вилучити", image: UIImage(named: "icons8-удалить-22")!, сolor: UIColor.white, backgroundColor: UIColor.red, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.deleteunit(forRowAtIndexPath: indexPath)
            success(true)
        })
        let editAction = self.contextualToggleAlltAction(forRowAtIndexPath: indexPath, title: "Змінити", image: UIImage(named: "icon edit pencil")!, сolor: UIColor.white, backgroundColor: UIColor.darkGray, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.indexPathSelect = indexPath
            self.editTapped(0)
            success(true)
        })
        
        let addAction = self.contextualToggleAlltAction(forRowAtIndexPath: indexPath, title: "Додати", image: UIImage(named: "icons8-добавить-23")!, сolor: UIColor.white, backgroundColor: UIColor.brown, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.indexPathSelect = indexPath
            self.addTapped(0)
            success(true)
        })
        
        let unit = fetchedResultsController.object(at: indexPathSelect!) as? Typecatalog
        var titleFavourite: String = "До обраного"
        var imageFavourite = UIImage(named:"icons8-сердце-30")
        if ( isFavourite(unit: unit!)) {
            titleFavourite = "З обраного"
            imageFavourite = UIImage(named: "icons8-червы-30")
        }
        
        let favouriteAction = self.contextualToggleAlltAction(forRowAtIndexPath: indexPath, title: titleFavourite, image: imageFavourite!, сolor: UIColor.white, backgroundColor: UIColor.magenta, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.indexPathSelect = indexPath
            self.changeFavourite(unit: unit)
            success(true)
        })
        
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [deleteAction,editAction,addAction,favouriteAction])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }
    
    public func changeFavourite(unit: Typecatalog!) {
        //       unit[self.fieldFavourite] = !unit.favouriteunit[self.fieldFavourite]
        //       CoreDataManager.instance.saveContext()
    }
    
    override public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.didSelect != nil {
            self.indexPathSelect = indexPath
            let choiceAction = self.contextualToggleAlltAction(forRowAtIndexPath: indexPath, title: "Вибрати", image: UIImage(named: "icons8-единый-выбор-filled-22")!, сolor: UIColor.white, backgroundColor: UIColor.blue, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                self.indexPathSelect = indexPath
                self.choiceTapped(0)
                success(true)
            })
            
            let swipeActionConfig = UISwipeActionsConfiguration(actions: [choiceAction])
            swipeActionConfig.performsFirstActionWithFullSwipe = false
            return swipeActionConfig
        } else {
            return nil
        }
    }


}

