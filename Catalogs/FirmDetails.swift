//
//  FirmDetails.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 31.10.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import UIKit
import CoreData


extension FirmDetails : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

class FirmDetails: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    var firmCoreData: Firms?
    var retRewriteFirm: Bool = false
    var modelController: ModelController!
    
    var menuTitles = ["Заповнити з ЄДР", "Зберегти", "Додати до обраного","Закрити", "Назад"]
    var menuPictures = ["cossack-30", "icons8-сохранить-filled-30", "icons8-сердце-30", "icons8-умножение-filled-30", "icons8-назад-filled-25"]
    var menuTitles2 = ["Заповнити з ЄДР", "Зберегти", "Вилучити з обраного","Закрити", "Назад"]
    var menuPictures2 = ["cossack-30", "icons8-сохранить-filled-30", "icons8-червы-30", "icons8-умножение-filled-30", "icons8-назад-filled-25"]
    
    @IBOutlet weak var menuButton: UIButton!
    
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
        popOverVCClass.setMenutitlesAndPictires(menuTitles1: menuTitles, menuPictures1: menuPictures, sizeSystemFont: 15, widthImage: 22, menuTitles2: menuTitles2, menuPictures2: menuPictures2) 
        if let firm = firmCoreData {
            popOverVCClass.favorite = firm.favourite
        }
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
           fillFromEDR()
        case 1:
            saveToCD()
        case 2:
            addTofavorite()
        case 4:
            cancelTapped(numMenu)
        default:
        //    print("No data")
            break
        }
        
    }
    
 //----------
    private func fillFromEDR() {
        let queryToEDR = QueryToEDR(feildName: "edrpou", countR: "1", startR: "0", view: self.view)
        self.scrollView.isUserInteractionEnabled = false
        let alpha = self.scrollView.alpha
        self.scrollView.alpha = alpha/2
        queryToEDR.executeQuery(textForSearch: self.edrpouField.text)
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.alpha = alpha
        switch queryToEDR.statusFinishOperation {
        case .ok:
            self.copyFromFirmEDRToTextField(edrfirms: queryToEDR.firms)
        default:
            break
        }
        let rezult = FirmDetails.receiveResponseServerEDR(statusOperation: queryToEDR.statusFinishOperation)
        self.showAlert(titleAlert: "Повідомлення", message: rezult, titleAction: "Ok", style: .cancel)
    }
    
//---------------
    class func receiveResponseServerEDR(statusOperation: StatusFinishGetDataOperation) -> String {
        var rezultRasponse: String = ""
        switch statusOperation {
        case .ok:
            rezultRasponse = "Дані з ЄДР отримано успішно!"
        case .cancel:
            rezultRasponse = "Переравно користувачем!"
        case .badrequest:
            rezultRasponse = "Невірно побудовано запит до ЄДР"
        case .createdresponse:
            rezultRasponse = "Запит виконано, але дані не отримані!"
        case .forbidden:
            rezultRasponse = "Доступ до ЄДР заборонено!"
        case .notfound:
            rezultRasponse = "Сайт ЄДР не знайдено! Перевірте Інтернет!"
        case .servererror:
            rezultRasponse = "Помилка сервера ЄДР!"
        case .unknown:
           rezultRasponse = "Невідома помилка!"
        case .encodeurl:
           rezultRasponse = "Невірний адрес (URL) запиту до ЄДР!"
        case .nilresponse:
           rezultRasponse = "Порожній заголовок відповіді сервера ЄДР!"
        case .nodata:
           rezultRasponse = "Порожня відповідь сервера ЄДР!"
        case .errordecode:
            rezultRasponse = "Помилка при декодуванні даних з сервера ЄДР!"
        }
        return rezultRasponse
    }
 //------------
    private func copyFromFirmEDRToTextField(edrfirms: edrFirms!) {
        if let edrFirms = edrfirms {
            if edrFirms.firms.count > 0 {
                let edrFirm = edrFirms.firms[0]
                copyFromEdrFirmToTextfield(edrFirm: edrFirm)
            }
        }
        
    }
  //-----------------
    private func copyFromEdrFirmToTextfield(edrFirm: edrFirm)  {
        self.adressField.text = edrFirm.address
        self.createdateField.text = (edrFirm.createdAt as Date).convertToString(format: "dd.MM.yyyy")
        self.edrpouField.text = edrFirm.edrpou
        self.headerField.text = edrFirm.mainPerson
        self.idFirm = edrFirm.id
        self.nameField.text = edrFirm.name
        self.occupationField.text = edrFirm.occupation
        self.officalnameField.text = edrFirm.officialName
        self.statusField.text = edrFirm.status
        self.updatedateField.text = (edrFirm.updatedAt as Date).convertToString(format: "dd.MM.yyyy")
    }
//----------
    private func saveToCD() {
        let edrpou = edrpouField.text
        var message = ""
        if let firm = firmCoreData {
            let firmTwin = Firms.getFirmFromCDbyEDRPU(edrpou: edrpou!)
            if (firmTwin == nil) || (firmTwin == firm) {
                self.copyDataFromView(firm: firm)
                updateCoreDateAsyn()
                message = "Дані юридичної особи з кодом \(edrpou ?? "") записано!"
            } else {
                rewriteFirm(firm: firm)
                if self.retRewriteFirm {
                        let managedObject = firmTwin as! NSManagedObject
                        CoreDataManager.instance.managedObjectContext.delete(managedObject)
                        updateCoreDateAsyn()
                        message = "Дані юридичної особи з кодом \(edrpou ?? "") перезаписано!"
                }
            }
            
        } else {
            var firm = Firms.getFirmFromCDbyEDRPU(edrpou: edrpou!)
            if  firm == nil {
                firm = Firms()
                self.copyDataFromView(firm: firm!)
                self.firmCoreData = firm
                updateCoreDateAsyn()
                let newElement = EdrpouToFirmCoreData(edrpou: firm!.edrpou!, firmCoreData: firm!)
                self.modelController.edrpouToFirmCoreData.append(newElement)

                message = "Дані юридичної особи з кодом \(edrpou ?? "") записано!"
            } else {
                rewriteFirm(firm: firm!)
                if self.retRewriteFirm {
                    message = "Дані юридичної особи з кодом \(edrpou ?? "") перезаписано!"
                }
            }
        }
        if message != "" {
            let alert = UIAlertController(title: "Сповіщення", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
//----------
    func rewriteFirm(firm : Firms) {
        let alert = UIAlertController(title: "Попередження", message: "Юридична особа з вказаним кодом за ЕДРПОУ існує! Перезаписати?", preferredStyle: .alert)
        self.retRewriteFirm = false
        alert.addAction(UIAlertAction(title: "Так", style: .destructive, handler:{  (UIAlertAction) -> Void in
            self.copyDataFromView(firm: firm)
            self.updateCoreDateAsyn()
            self.retRewriteFirm = true
        }))
        
        alert.addAction(UIAlertAction(title: "Ні", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
//----------
    func copyDataFromView(firm: Firms){
        firm.address = adressField.text
        firm.createdAt =  createdateField.text!.convertToDate(format: "dd.MM.yyyy") == nil ? nil : createdateField.text!.convertToDate(format: "dd.MM.yyyy") as NSDate
        firm.edrpou = edrpouField.text
        firm.mainPerson = headerField.text
        firm.name = nameField.text
        firm.occupation = occupationField.text
        firm.officialName = officalnameField.text
        firm.status = statusField.text
        firm.updatedAt = updatedateField.text!.convertToDate(format: "dd.MM.yyyy") == nil ? nil : updatedateField.text!.convertToDate(format: "dd.MM.yyyy")as NSDate
        firm.id = self.idFirm
    }
    //-------------
    private func addTofavorite() {
        if let firm = firmCoreData {
            firm.favourite = !firm.favourite
            updateCoreDateAsyn()
            if firm.favourite {
                self.edrpouField.textColor = .magenta
            } else {
                self.edrpouField.textColor = .black
            }
        } else {
                answerBeforeSave()
        }
    }
    
    private func answerBeforeSave() {
        let alert = UIAlertController(title: "Попередження", message: "Юридична особа з вказаним кодом за ЕДРПОУ не збережно! Записати?", preferredStyle: .alert)
        self.retRewriteFirm = false
        alert.addAction(UIAlertAction(title: "Так", style: .destructive, handler:{  (UIAlertAction) -> Void in
            self.saveToCD()
         }))
        
        alert.addAction(UIAlertAction(title: "Ні", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }

//---------------
    private func dataWasChanged() -> Bool {
        if (self.firmCoreData == nil) && (self.adressField.text?.isEmpty)! && (self.createdateField.text?.isEmpty)! && (self.edrpouField.text?.isEmpty)!
            && (self.headerField.text?.isEmpty)! && (self.nameField.text?.isEmpty)! && (self.occupationField.text?.isEmpty)! && (self.officalnameField.text?.isEmpty)!
            && (self.statusField.text?.isEmpty)! && (self.updatedateField.text?.isEmpty)!  {
               return true
        }
        
        if self.firmCoreData == nil {
            return false
        }
        
        if self.firmCoreData?.address != self.adressField.text {
            return false
        }
        if self.firmCoreData?.createdAt != (self.createdateField.text!.convertToDate(format: "dd.MM.yyyy") == nil ? nil : self.createdateField.text!.convertToDate(format: "dd.MM.yyyy") as NSDate) {
            return false
        }
       if self.firmCoreData?.edrpou != self.edrpouField.text {
            return false
        }
       if self.firmCoreData?.mainPerson != self.headerField.text {
            return false
        }
       if self.firmCoreData?.name != self.nameField.text {
            return false
        }
       if self.firmCoreData?.occupation != self.occupationField.text {
            return false
        }
       if self.firmCoreData?.officialName != self.self.officalnameField.text {
            return false
        }
       if self.firmCoreData?.status != self.self.statusField.text{
            return false
        }
        if self.firmCoreData?.updatedAt != (self.updatedateField.text!.convertToDate(format: "dd.MM.yyyy") == nil ? nil : self.updatedateField.text!.convertToDate(format: "dd.MM.yyyy") as NSDate) {
            return false
        }
        return true
    }


    @IBAction func cancelTapped(_ sender: Any) {
         if dataWasChanged() {
            dismiss(animated: true, completion: nil)
         } else {
            alertForSaveData()
       }
    }
//--------------
   private func alertForSaveData() {
        let alert = UIAlertController(title: "Попередження", message: "Дані було змінено! Зберегти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Так", style: .destructive, handler:{  (UIAlertAction) -> Void in
            self.saveToCD()
        }))
        
        alert.addAction(UIAlertAction(title: "Ні", style: .cancel, handler: { (UIAlertAction) -> Void in
           
                self.dismiss(animated: true)
        } ))
        self.present(alert, animated: true, completion: nil)
        
    }

    //--------------
    @IBAction func phoneButtonTapped(_ sender: Any) {
        if self.firmCoreData == nil {
            answerBeforeSave()
        } else {
            performSegue(withIdentifier: "phoneController", sender: sender)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    weak var activeField: UITextField?
    weak var activeViewField: UITextView?
    
    @IBOutlet weak var edrpouField: UITextField!
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var occupationField: UITextView!
    @IBOutlet weak var officalnameField: UITextView!
    @IBOutlet weak var adressField: UITextView!
    @IBOutlet weak var headerField: UITextField!
    @IBOutlet weak var createdateField: UITextField!
    @IBOutlet weak var updatedateField: UITextField!
   
    var idFirm: Int64 = 0
    
    let loadDataQueue = DispatchQueue(label: "com.ConnectToEDR.getData")
    
    private func updateCoreDateAsyn() {
        self.loadDataQueue.async {
            CoreDataManager.instance.saveContext()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUserInteractionEnable()
        setSCRViewControl()
        setTextField()
        initializeTextFieldInputView(textField: edrpouField)
        initializeDateTextFieldInputView(textField: createdateField)
        initializeDateTextFieldInputView(textField: updatedateField)
        
    }
    
    func setSCRViewControl() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    func setUserInteractionEnable()
    {
 /*       if self.firmCoreData != nil {
            self.phoneSegueButton.isUserInteractionEnabled = true
        } else {
            self.phoneSegueButton.isUserInteractionEnabled = false
        }
 */
    }
    
    func setTextField() {
        self.edrpouField.delegate = self
        self.statusField.delegate = self
        self.nameField.delegate = self
        self.occupationField.delegate = self
        self.officalnameField.delegate = self
        self.adressField.delegate = self
        self.headerField.delegate = self
        self.createdateField.delegate = self
        self.updatedateField.delegate = self
        if let firm = self.firmCoreData {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            if firm.favourite {
                self.edrpouField.textColor = .magenta
            }
            self.edrpouField.text = firm.edrpou
            self.statusField.text = firm.status
            self.nameField.text   = firm.name
            self.occupationField.text = firm.occupation
            self.officalnameField.text = firm.officialName
            self.adressField.text = firm.address
            self.headerField.text = firm.mainPerson
            self.createdateField.text = firm.createdAt == nil ? "" : (firm.createdAt! as Date).convertToString(format: "dd.MM.yyyy")
            self.updatedateField.text = firm.updatedAt == nil ? "" : (firm.updatedAt! as Date).convertToString(format: "dd.MM.yyyy")
            self.idFirm = firm.id
        }

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "phoneController" {
            let controller = segue.destination as! PhoneTabBarController
            if let firm = self.firmCoreData {
                controller.modelPhone.firm = firm
            }
        }
        
    }

}

