//
//  Firms+CoreDataProperties.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 23.10.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//
//

import Foundation
import CoreData


extension Firms {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Firms> {
        return NSFetchRequest<Firms>(entityName: "Firms")
    }

    @NSManaged public var id: Int64
    @NSManaged public var address: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var edrpou: String?
    @NSManaged public var mainPerson: String?
    @NSManaged public var name: String?
    @NSManaged public var occupation: String?
    @NSManaged public var officialName: String?
    @NSManaged public var status: String?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var favourite: Bool
    
    class func Equal(left: Firms!, right: Firms!) -> Bool {
        if left == nil && right == nil {
            return true
        }
        if left == nil {
            return false
        }
        if right == nil {
            return false
        }

        if left.id != right.id {
            return false
        }
        if left.address != right.address {
            return false
        }
        if left.createdAt != right.createdAt {
            return false
        }
        if left.edrpou != right.edrpou {
            return false
        }
        if left.mainPerson != right.mainPerson {
            return false
        }
        if left.name != right.name {
            return false
        }
        if left.occupation != right.occupation {
            return false
        }
        if left.officialName != right.officialName {
            return false
        }
        if left.status != right.status {
            return false
        }
        if left.updatedAt != right.updatedAt {
            return false
        }
        if left.favourite != right.favourite {
            return false
        }
        return true
    }
    
    class func NotEqual(left: Firms, right: Firms) -> Bool {
          return !Firms.Equal(left: left, right: right)
    }
    
    class func copyFromEdrStruct(firmCoreData: Firms, firm: edrFirm) {
        firmCoreData.id = firm.id
        firmCoreData.address = firm.address
        firmCoreData.createdAt = firm.createdAt as NSDate
        firmCoreData.edrpou = firm.edrpou
        firmCoreData.mainPerson = firm.mainPerson
        firmCoreData.name = firm.name
        firmCoreData.occupation = firm.occupation
        firmCoreData.officialName = firm.officialName
        firmCoreData.status = firm.status
        firmCoreData.updatedAt = firm.updatedAt as NSDate
        
    }
    
    class func getFirmFromCDbyEDRPU(edrpou: String) -> Firms! {
        let predicate = NSPredicate(format: "edrpou = %@",  edrpou)
        let fetchedResultsController = CoreDataManager.instance.fetchedResultsController(entityName: "Firms", keyForSort: "edrpou", predicate: predicate)
        do {
            try fetchedResultsController.performFetch()
            let filteredImemsCount = fetchedResultsController.sections![0].numberOfObjects
            if filteredImemsCount > 0 {
                return fetchedResultsController.object(at: IndexPath(row: 0, section: 0)) as? Firms
            } else {
                return nil
            }
        }
        catch{
            print(error)
            return nil
        }
    }
}
