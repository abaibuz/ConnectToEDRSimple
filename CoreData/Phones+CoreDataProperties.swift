//
//  Phones+CoreDataProperties.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 03.12.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//
//

import Foundation
import CoreData


extension Phones {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Phones> {
        return NSFetchRequest<Phones>(entityName: "Phones")
    }

    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var person: String?
    @NSManaged public var phoneFirm: Firms?
    
    class func Equal(left: Phones!, right: Phones!) -> Bool {
        if left == nil && right == nil {
            return true
        }
        if left == nil {
            return false
        }
        if right == nil {
            return false
        }
        
        if left.name != right.name {
            return false
        }
        if left.person != right.person {
            return false
        }
        if left.phone != right.phone {
            return false
        }
        
        if Firms.NotEqual(left: left.phoneFirm!, right: right.phoneFirm!){
            return false
        }
        return true
    }
    
    class func NotEqual (left: Phones, right: Phones) -> Bool {
        return !Phones.Equal(left: left, right: right)
    }
}
