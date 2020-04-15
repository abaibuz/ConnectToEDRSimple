//
//  Phones+CoreDataClass.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 03.12.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Phones)
public class Phones: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "Phones"),
                  insertInto: CoreDataManager.instance.managedObjectContext)
    }
    

}
