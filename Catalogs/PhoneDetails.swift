//
//  PhoneDetails.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 02.12.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation
import UIKit

extension PhoneDetails : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

class PhoneDetails: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    var firm: Firms?
    var phone: Phones?
    weak var activeField: UITextField?
    
    @IBOutlet weak var firmLabel: UILabel!
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        if dataWasChanged() {
            dismiss(animated: true)
        } else {
            self.alertForSaveData(isExit: true)
       }
    }
    
    private func alertForSaveData(isExit: Bool) {
        let alert = UIAlertController(title: "Попередження", message: "Дані було змінено! Зберегти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Так", style: .destructive, handler:{  (UIAlertAction) -> Void in
            self.savePhone()
        }))
        
        alert.addAction(UIAlertAction(title: "Ні", style: .cancel, handler: { (UIAlertAction) -> Void in
            if isExit {
                self.dismiss(animated: true)
            }
        } ))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func dataWasChanged() -> Bool {
        if (self.phone == nil) && (self.nameField.text?.isEmpty)! && (self.numberPhoneField.text?.isEmpty)! && (self.personField.text?.isEmpty)! {
            return true
        }
        
        if self.phone == nil {
            return false
        }
        
        if self.phone?.name != self.nameField.text {
            return false
        }
        if self.phone?.person != self.personField.text {
            return false
        }
        if self.phone?.phone != self.numberPhoneField.text {
            return false
        }

        return true
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        self.callPhone(phoneNumber: numberPhoneField.text!)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberPhoneField: UITextField!
    @IBOutlet weak var personField: UITextField!
  
    @IBOutlet weak var menuButton: UIButton!

    var menuTitles = ["Зберегти", "Викликати", "До контактів", "Закрити", "Назад"]
    var menuPictures = ["icons8-сохранить-filled-30", "icons8-громкость-звонка-30", "icons8-контакты-30", "icons8-умножение-filled-30", "icons8-назад-filled-25"]
    
    
    @IBAction func menuButtonTapped(_ sender: Any) {
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
        popOverVCClass.choiceCellNum = { [unowned self] num in
            if num >= 0 {
                //             popVC.dismiss(animated: true)
                self.runMenuFunc(numMenu: num)
            }
        }
        
        self.present(popVC, animated: true)
        
    }
 
    
    private func runMenuFunc(numMenu: Int) {
        switch numMenu {
        case 0:
            savePhone()
        case 1:
            callButtonTapped(numMenu)
        case 2:
            createContactFromPhone()
        case 4:
            cancelButtonTapped(numMenu)
        default:
            break
        }
        
    }

    //
    private func createContactFromPhone() {
       if let phone = self.phone {
            self.createContact(phoneCD: phone)
        } else {
          let alert = UIAlertController(title: "Попередження", message: "Введіть та збережіть дані для занесення їх до контактів!", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Ок", style: .destructive))
          self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    //
    private func savePhone() {
        if !validateData() {
           return
        }
        var phone = self.phone
        if  phone == nil {
            phone = Phones()
        }
        self.copyDataFromTexrFieldToPhone(phone: phone!)
        CoreDataManager.instance.saveContext()
        self.phone = phone
    }
    
    private func copyDataFromTexrFieldToPhone(phone: Phones!) {
        phone.name = self.nameField.text
        phone.phone = self.numberPhoneField.text
        phone.person = self.personField.text
        phone.phoneFirm = self.firm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFirm()
        setSCRViewControl()
        initializeTextFieldInputView(textField: numberPhoneField)
    }
    
    private func setFirm() {
        if let firm = self.firm {
            self.firmLabel.text = firm.name! + "(" + firm.edrpou! + ")"
        }
        if let phone = self.phone {
            self.nameField.text = phone.name
            self.numberPhoneField.text = phone.phone
            setColorTextField(textField: self.numberPhoneField, phone: phone)
            self.personField.text = phone.person
        }
    }
    
    //-----------------------
    private func setColorTextField(textField: UITextField, phone: Phones) {
        let existContact = fetcthExistContacts(phoneCD : phone)
        if existContact.count > 0 {
            textField.textColor = .red
        }
    }
    
    
    private func setSCRViewControl() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private func initializeTextFieldInputView(textField: UITextField) {
        // Add toolbar with done button on the right
        let toolbar = UIToolbar()
        let flexibleSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        toolbar.items = [flexibleSeparator, doneButton]
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        if let activeField = self.activeField {
            let activeRect = activeField.convert(activeField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(activeRect, animated: true)
            return
        }
        
     }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func doneButtonPressed(_ sender: Any) {
        activeField?.resignFirstResponder()
    }

    func validateData() -> Bool  {
        var returnCode = true
        var title = "Повідомлення"
        var style = UIAlertAction.Style.default
        var message = "Дані по телефону \(numberPhoneField.text ?? "") збережено!"
        let numberSymbols = numberPhoneField.text?.count
        
        if (nameField.text?.isEmpty)! && numberSymbols! < 10 {
            style = .cancel
            title = "Попередження"
            message = "Введіть назву та номер телефону (не менше 10 цифр)!"
            returnCode = false
        } else if (nameField.text?.isEmpty)! {
            style = .cancel
            title = "Попередження"
            message = "Введіть назву!"
            returnCode = false
        } else if numberSymbols! < 10 {
            style = .cancel
            returnCode = false
            title = "Попередження"
            message = "Введіть номер телефону (не менше 10 цифр)!"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: style, handler: nil))
        self.present(alert, animated: true, completion: nil)

        return returnCode
    }

    
    
}
