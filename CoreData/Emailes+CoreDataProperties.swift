//
//  Emailes+CoreDataProperties.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 03.12.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//
//

import Foundation
import CoreData


extension Emailes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Emailes> {
        return NSFetchRequest<Emailes>(entityName: "Emailes")
    }

    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var person: String?
    @NSManaged public var emailFirm: Firms?

}
