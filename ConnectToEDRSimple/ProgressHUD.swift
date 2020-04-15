//
//  ProgressHUD.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 29.09.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation
import UIKit

class ProgressHUD: UIVisualEffectView {
    
    var text: String? {
        didSet {
            button.setTitle(text, for: .normal)
        }
    }
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    let blurEffect = UIBlurEffect(style: .light)
    let vibrancyView: UIVisualEffectView
    let button: UIButton = UIButton(type: .system)
    var operation = GetDataFromEDR(url: "")
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        contentView.addSubview(activityIndictor)
        contentView.addSubview(button)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width = superview.frame.size.width / 2.3
            let height: CGFloat = 50.0
            self.frame = CGRect(x: superview.frame.size.width / 2 - width / 2,
                                y: superview.frame.height / 2 - height / 2,
                                width: width,
                                height: height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(x: 5,
                                            y: height / 2 - activityIndicatorSize / 2,
                                            width: activityIndicatorSize,
                                            height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            button.frame = CGRect(x: activityIndicatorSize + 5,
                                 y: 0,
                                 width: width - activityIndicatorSize - 15,
                                 height: height)
            button.setTitle(text, for: .normal)
            button.backgroundColor = UIColor.init(displayP3Red: 0.9, green: 0.1, blue: 0.1, alpha: 1)
            button.addTarget(self, action: #selector(self.CancelOperation(_:)),  for: .touchUpInside)
            
        }
    }
    
    @objc func CancelOperation(_ sender: UIButton){
        if  !self.operation.isFinished {
            self.operation.statusFinishOperation = .cancel
            self.operation.cancel()
        }
    }
    
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}
