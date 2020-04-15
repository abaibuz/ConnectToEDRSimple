//
//  Firms+CoreDataClass.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 23.10.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Firms)
public class Firms: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "Firms"),
                  insertInto: CoreDataManager.instance.managedObjectContext)
    }
    
    

}
