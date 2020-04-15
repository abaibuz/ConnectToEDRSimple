//
//  Information.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 05.01.2019.
//  Copyright © 2019 Baibuz Oleksandr. All rights reserved.
//

import UIKit

class Information: UITableViewController {
    var tableArray = [[[String]]]()
//    var menuTitles: [String] = ["Опис програми", "Угода з кінцевим користувачем"]
//    var menuPictures: [String] = ["icons8-режим-чтения-в-chrome-30", "icons8-лицензия-30"]
    var sizeSystemFont: CGFloat = 18.0
    var widthImage: CGFloat = 25.0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
        tableArray = [[["manual","Опис програми","icons8-режим-чтения-в-chrome-30"]], [["lic","Лицензійна угода","icons8-лицензия-30"]]]
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell!.textLabel?.text = tableArray[indexPath.row][0][1]
        cell!.textLabel?.textColor = .systemBlue
        cell!.textLabel?.font = UIFont.systemFont(ofSize: self.sizeSystemFont)
        let image = UIImage(named: tableArray[indexPath.row][0][2])?.withRenderingMode(.alwaysTemplate)
        let image2 = image?.resizeWith(width: self.widthImage)
        cell!.imageView?.image = image2
        cell!.imageView?.tintColor = .systemBlue
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "aboutApp" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = segue.destination as! License
                controller.titleNavigationBar = tableArray[indexPath.row][0][1]
                if let path = Bundle.main.url(forResource: tableArray[indexPath.row][0][0], withExtension: "rtf") {
                    do {
                        let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: path, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                        controller.texViewContent = attributedStringWithRtf
                    } catch let error {
                        print("Got an error \(error)")
                    }
                }
            }
            
        }
        
    }
    
}
