//
//  License.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 06.01.2019.
//  Copyright © 2019 Baibuz Oleksandr. All rights reserved.
//

import UIKit

class License: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var textView: UITextView!
    
    var titleNavigationBar: String = ""
    var texViewContent = NSAttributedString()
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.topItem?.title = titleNavigationBar
        textView.attributedText = texViewContent
        textView.isEditable = false
    }

}
