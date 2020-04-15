//
//  myExtension.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 15.10.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

extension String{
    var encodeUrl : String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    var decodeUrl : String
    {
        return self.removingPercentEncoding!
    }
    
    func convertToDate(format: String) -> Date!{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self) ?? nil
    }
    
}

extension Date {
    var convertDateToString : String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = .none
        dateformatter.locale = Locale(identifier: "uk_UA")
        let stringDate = dateformatter.string(from: self)
        return stringDate
    }
    
    func convertToString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}


extension UIColor {
    static let candyGreen = UIColor(red: 67.0/255.0, green: 205.0/255.0, blue: 135.0/255.0, alpha: 1.0)
    static let systemBlue = UIColor(red: 0, green: 122.0/255.0, blue: 1, alpha: 1)
}


struct edrFirm: Codable{
    var address: String
    var createdAt: Date
    var edrpou: String
    var id: Int64
    var mainPerson: String
    var name: String
    var occupation: String
    var officialName: String
    var status: String
    var updatedAt: Date
}

struct edrFirms: Codable {
    var firms: [edrFirm]
}

struct EdrpouToFirmCoreData {
    var edrpou: String
    var firmCoreData: Firms?
    init(edrpou: String, firmCoreData: Firms) {
        self.edrpou = edrpou
        self.firmCoreData = firmCoreData
    }
}

class ModelController {
    var edrpouToFirmCoreData: [EdrpouToFirmCoreData] = []
    var searchIsActive = false
    var textSearch = ""
}

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Скасувати", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Виконано", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

extension UISearchBar {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Скасувати", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Виконано", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

class ModelTabBarController : UITabBarController {
    var modelController = ModelController()
}

class ModelPhoneTabBarController {
    var firm: Firms!
}

class PhoneTabBarController: UITabBarController {
    var modelPhone = ModelPhoneTabBarController()
    
/*
    override func viewDidLoad() {
        super.viewDidLoad()
        //        selectedIndex = 1
        selectedViewController = viewControllers![0]
        /// Set the animation type for swipe
        setSwipeAnimation(type: SwipeAnimationType.sideBySide)
        /// Set the animation type for tap
        setTapAnimation(type: SwipeAnimationType.sideBySide)
        
        /// Disable custom transition on tap.
        //        setTapTransitioning(transition: nil)
        
        /// Set swipe to only work when strictly horizontal.
        setDiagonalSwipe(enabled: false)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Handle didSelect viewController method here
    }
 */
}

enum StatusFinishGetDataOperation {
    case cancel
    case ok  //200
    case badrequest //400
    case createdresponse //201
    case forbidden //403
    case notfound //404
    case servererror // 500
    case unknown
    case encodeurl
    case nilresponse
    case nodata
    case errordecode
}


@IBDesignable extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}

struct TextFieldAndView {
    var activeField: UITextField?
    var activeViewField: UITextView?
}

extension UITableViewController {
    
    public func fixAction(title: String, image:UIImage, сolor: UIColor, rowHeight: CGFloat) -> UIImage! {
        // make sure the image is a mask that we can color with the passed color
        let mask = image.withRenderingMode(.alwaysTemplate)
        // compute the anticipated width of that non empty string
        let titleAction = NSString(string: title)
        let stockSize = titleAction.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white])
        // I know my row height
        let height:CGFloat = rowHeight + 2
        // Standard action width computation seems to add 15px on either side of the text
        let width = (stockSize.width + 30).rounded()
        let actionSize = CGSize(width: width, height: height)
        // lets draw an image of actionSize
        UIGraphicsBeginImageContextWithOptions(actionSize, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            context.clear(CGRect(origin: .zero, size: actionSize))
        }
        сolor.set()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes = [NSAttributedString.Key.foregroundColor: сolor, NSAttributedString.Key.font: UIFont(name: "Avenir-Book", size: 12), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        //      title.size(withAttributes: [NSAttributedStringKey : Any]?)
        let textSize = title.size(withAttributes: attributes as [NSAttributedString.Key : Any] )
        // implementation of `half` extension left up to the student
        let textPoint = CGPoint(x: (width - textSize.width)/2, y: (height - (textSize.height * 3))/2 + (textSize.height * 2))
        title.draw(at: textPoint, withAttributes: attributes as [NSAttributedString.Key : Any] )
        let maskHeight = textSize.height * 2
        let maskRect = CGRect(x: (width - maskHeight)/2, y: textPoint.y - maskHeight, width: maskHeight, height: maskHeight)
        mask.draw(in: maskRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    public func contextualToggleAlltAction(forRowAtIndexPath indexPath: IndexPath, title: String, image: UIImage, сolor: UIColor, backgroundColor: UIColor,  handler: @escaping UIKit.UIContextualAction.Handler) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title:  "", handler: handler)
        let cell = tableView.cellForRow(at: indexPath)
        let rowHeight = (cell?.frame.height)!
        if let newImage = self.fixAction(title: title, image: image, сolor: сolor, rowHeight: rowHeight) {
            action.image = newImage
        } else {
            action.image = image
        }
        action.backgroundColor = backgroundColor
        return action
    }
}

extension UIViewController: MFMailComposeViewControllerDelegate {
    
    public func callPhone(phoneNumber: String) {
        if let phoneCallURL:URL = URL(string: "tel:\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                let alertController = UIAlertController(title: "Запит до ЄДР", message: "Викликати телефоний номер \n\(phoneNumber)?", preferredStyle: .alert)
                let yesPressed = UIAlertAction(title: "Так", style: .default, handler: { (action) in
                    application.open(phoneCallURL, options: [:], completionHandler: nil)//  openURL(phoneCallURL)
                })
                let noPressed = UIAlertAction(title: "Ні", style: .default, handler: { (action) in
                    
                })
                alertController.addAction(yesPressed)
                alertController.addAction(noPressed)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    public func configureMailComposer(recipients: [String], subject: String, body: String) -> MFMailComposeViewController{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(recipients)
        mailComposeVC.setSubject(subject)
        mailComposeVC.setMessageBody(body, isHTML: false)
        return mailComposeVC
    }
}

