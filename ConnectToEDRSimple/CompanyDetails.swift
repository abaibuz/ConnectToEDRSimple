//
//  CompanyDetails.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 11.10.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import UIKit

class CompanyDetailes : UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var edrFirms : edrFirm?
    var firmCoreData: Firms?
    var modelController: ModelController!

    @IBOutlet weak var edrpouField: UITextField!    
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var headerField: UITextField!
    @IBOutlet weak var officialnameField: UITextView!
    @IBOutlet weak var occupationField: UITextView!
    @IBOutlet weak var updateAtField: UITextField!
    
    @IBOutlet weak var AdresField: UITextView!
    @IBOutlet weak var creatAtField: UITextField!
    
    @IBAction func TyppedSaveButton(_ sender: Any) {
        var firm = self.firmCoreData
        if  firm == nil {
            firm = Firms()
            if let edrFirms = self.edrFirms {
                Firms.copyFromEdrStruct(firmCoreData: firm!, firm: edrFirms)
                self.copyDataFromView(firm: firm!)
                CoreDataManager.instance.saveContext()
                let newElement = EdrpouToFirmCoreData(edrpou: edrFirms.edrpou, firmCoreData: firm!)
                self.modelController.edrpouToFirmCoreData.append(newElement)
                self.firmCoreData = firm
                self.edrpouField.textColor = .red
                self.edrpouField.setNeedsDisplay()
                self.edrpouField.layoutIfNeeded()
            }
        } else {
           self.rewriteFirm(firm: firm!)
        }
        
        
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    weak var activeField: UITextField?
    weak var activeViewField: UITextView?

    func rewriteFirm(firm : Firms)  {
        let alert = UIAlertController(title: "Попередження", message: "Юридична особа з вказаним кодом за ЕДРПОУ існує! Перезаписати?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Так", style: .destructive, handler:{  (UIAlertAction) -> Void in
            self.copyDataFromView(firm: firm)
            CoreDataManager.instance.saveContext()
           
        }))
        
        alert.addAction(UIAlertAction(title: "Ні", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func copyDataFromView(firm: Firms){
        firm.address = self.AdresField.text
        firm.mainPerson = self.headerField.text
        firm.name = self.nameField.text
        firm.occupation = self.occupationField.text
        firm.officialName = self.officialnameField.text
        firm.status = self.statusField.text
        firm.createdAt = self.creatAtField.text!.convertToDate(format: "dd.MM.yyyy") as NSDate
        firm.updatedAt = self.updateAtField.text!.convertToDate(format: "dd.MM.yyyy") as NSDate
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSCRViewControl()
        setTextField()
        initializeTextFieldInputView(textField: edrpouField)
        initializeDateTextFieldInputView(textField: creatAtField)
        initializeDateTextFieldInputView(textField: updateAtField)

        
    }
    
    //------------------
    func setTextField() {
        self.edrpouField.delegate = self
        self.statusField.delegate = self
        self.nameField.delegate = self
        self.occupationField.delegate = self
        self.officialnameField.delegate = self
        self.AdresField.delegate = self
        self.headerField.delegate = self
        self.creatAtField.delegate = self
        self.updateAtField.delegate = self
        if let firm = self.edrFirms {
            self.nameField.text = firm.name
            
            self.edrpouField.text = firm.edrpou
            if  self.firmCoreData != nil {
                self.edrpouField.textColor = .red
            }
            self.statusField.text = firm.status
            self.officialnameField.text = firm.officialName
            self.headerField.text = firm.mainPerson
            self.occupationField.text = firm.occupation
            self.creatAtField.text = (firm.createdAt as Date).convertToString(format: "dd.MM.yyyy")
            self.updateAtField.text = (firm.updatedAt as Date).convertToString(format: "dd.MM.yyyy")
            self.AdresField.text = firm.address
        }

    }
    
    //-----------------
    func setSCRViewControl() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func initializeDateTextFieldInputView(textField: UITextField) {
        // Add date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateSelectedFromDataPicker(_:)), for: .valueChanged)
        textField.inputView = datePicker
        
        // Add toolbar with done button on the right
        self.initializeTextFieldInputView(textField: textField)
    }
    
    func initializeTextFieldInputView(textField: UITextField) {
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
        activeViewField = nil
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeViewField = textView
        activeField = nil
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeViewField = nil
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
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
        
        if let activeView = self.activeViewField {
            let activeRect = activeView.convert(activeView.bounds, to: scrollView)
            scrollView.scrollRectToVisible(activeRect, animated: true)
            return
        }
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func dateSelectedFromDataPicker(_ datePicker: UIDatePicker) {
        activeField?.text = datePicker.date.convertToString(format: "dd.MM.yyyy")
    }
    
    @objc func doneButtonPressed(_ sender: Any) {
        activeField?.resignFirstResponder()
    }
    

}
