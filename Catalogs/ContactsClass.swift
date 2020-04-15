//
//  ContactsClass.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 05.12.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation
import Contacts
import UIKit


extension  UIViewController {
    
    public func createContact(phoneCD : Phones) {
        let numberPhone = phoneCD.phone
        let existContact = fetcthExistContacts(phoneCD : phoneCD)
        if existContact.count > 0 {
            updateContact(existContact: existContact[0], phoneCD : phoneCD)
        } else {
           let newContact = CNMutableContact()
            writeFieldContact(contact: newContact, phoneCD: phoneCD)
            // Saving contact
            let store = CNContactStore()
            let saveRequest = CNSaveRequest()
            saveRequest.add(newContact, toContainerWithIdentifier:nil)
            try! store.execute(saveRequest)
            showAlert(titleAlert: "Інформація", message: "Контакт з номером телефону \(numberPhone ?? "") додано!", titleAction: "Ok", style: .cancel)
        }
    }
    
    func writeFieldContact(contact: CNMutableContact, phoneCD: Phones) {
        let numberPhone = phoneCD.phone
        let namePhone = phoneCD.name
        let person = phoneCD.person
        let firmName = phoneCD.phoneFirm?.name
        if person!.isEmpty {
            contact.givenName = firmName!
        } else {
            contact.givenName = person!
            contact.organizationName = firmName!
        }
        contact.phoneNumbers = [CNLabeledValue(
            label:namePhone!,
            value:CNPhoneNumber(stringValue: numberPhone!))]
    }
    
    func showAlert(titleAlert: String, message: String, titleAction: String, style: UIAlertAction.Style) {
        let alert = UIAlertController(title: titleAlert, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: titleAction, style: style, handler: nil))
        present(alert, animated: true, completion: nil)

    }
    
    public func updateContact(existContact: CNContact, phoneCD : Phones) {
        let numberPhone = phoneCD.phone
//        let namePhone = phoneParams["namePhone"]
//        let person = phoneParams["person"]
//        let firmName = phoneParams["firmName"]

        let alert = UIAlertController(title: "Попередження", message: "Контакт з номером телефону \(numberPhone ?? "") існує! Перезаписати?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Так", style: .destructive, handler:{  (UIAlertAction) -> Void in
           self.updateExistContacts(existContact: existContact, phoneCD: phoneCD)
            
        }))
        alert.addAction(UIAlertAction(title: "Ні", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    public func updateExistContacts(existContact: CNContact, phoneCD : Phones) {
        let mutableContact = existContact.mutableCopy() as! CNMutableContact
        writeFieldContact(contact: mutableContact, phoneCD: phoneCD)
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.update(mutableContact)
        try! store.execute(saveRequest)
        let numberPhone = phoneCD.phone
        showAlert(titleAlert: "Інформація", message: "Контакт з номером телефону \(numberPhone ?? "") оновлено!", titleAction: "Ok", style: .cancel)

    }
    
    public func fetcthExistContacts(phoneCD : Phones) -> [CNContact] {
        let predicate: NSPredicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phoneCD.phone!))
        let keysToFetch = [CNContactPhoneNumbersKey,CNContactGivenNameKey,CNContactOrganizationNameKey]
        let store = CNContactStore()
        var contact: [CNContact] = []
 //       DispatchQueue(label: "edr").async {
            contact = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
 //       }
        return contact
    }
}

