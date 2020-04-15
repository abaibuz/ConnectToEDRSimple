//
//  FirmsCatalog.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 23.10.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class firmsCatalog : Catalog<Firms>, UIPopoverPresentationControllerDelegate {
    
    var menuTitles = ["Додати", "Закрити"]
    var menuPictures = ["icons8-добавить-23", "icons8-умножение-filled-30"]
    
    @IBOutlet weak var menuButton: UIButton!
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") else {
            return
        }
        
        popVC.modalPresentationStyle = .popover
        
        let popOverVC = popVC.popoverPresentationController
        
        popOverVC?.delegate = self
        popOverVC?.sourceView = menuButton
        popOverVC?.sourceRect = CGRect(x: self.menuButton.bounds.minX, y: self.menuButton.bounds.maxY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: 240, height: 240)
        let popOverVCClass = popVC as! PopoverTableViewController
        popOverVCClass.setMenutitlesAndPictires(menuTitles1: menuTitles, menuPictures1: menuPictures, sizeSystemFont: 15, widthImage: 22, menuTitles2: nil, menuPictures2: nil)
        
        
   //     if let firm = firmCoreData {
            popOverVCClass.favorite = false
  //      }
        popOverVCClass.choiceCellNum = { [unowned self] num in
            if num >= 0 {
        //        popVC.dismiss(animated: true)
                self.runMenuFunc(numMenu: num)
            }
        }
        
        self.present(popVC, animated: true)


    }
    
    private func runMenuFunc(numMenu: Int) {
        switch numMenu {
        case 0:
            self.addTapped(numMenu)
        default:
            break
        }
        
    }

    
    var didSelectedTableView = false
    var modelController: ModelController!
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        self.entityName = "Firms"
        self.fieldForSort = "edrpou"
        self.fieldForSearch = "name"
        self.fieldFavourite = "favourite"
        self.segueAddEdit = "FirmsCatalogToFirm"
        
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FirmsCatalogToFirm" {
            let controller = segue.destination as! FirmDetails
            controller.firmCoreData = sender as? Firms
            controller.modelController = self.modelController
            self.didSelectedTableView = true
        }
        
    }
    override public func changeFavourite(unit: Firms!) {
        unit.favourite = !unit.favourite
        CoreDataManager.instance.saveContext()
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let unit = fetchedResultsController.object(at: indexPath) as! Firms
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        fillCell(cell: cell, unit: unit)
        return cell

    }

    override public func fillCell(cell: UITableViewCell, unit : Firms)  {
        if unit.favourite {
            cell.textLabel?.textColor = .magenta
            cell.detailTextLabel?.textColor = .magenta
        }
        cell.textLabel?.text = unit.name
        cell.detailTextLabel?.text = unit.edrpou
    }
    
    override func isFavourite(unit: Firms) -> Bool {
        return unit.favourite
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tbc = self.tabBarController as? ModelTabBarController {
            self.modelController = tbc.modelController
        }
    }
    
    override func addGestureTableCell() {

    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        let tappoint = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: tappoint) {
            indexPathSelect = indexPath
            
        }
    }
    
    override func deleteAlertAction(indexPath: IndexPath) {
        let firm = fetchedResultsController.object(at: indexPath) as! Firms
        let firmsCD = self.modelController.edrpouToFirmCoreData.filter { $0.edrpou != firm.edrpou }
        self.modelController.edrpouToFirmCoreData = firmsCD
        super.deleteAlertAction(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        self.editTapped(0)
    }

}
