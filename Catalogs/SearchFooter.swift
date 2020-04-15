//
//  SearchFooter.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 23.10.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import UIKit

class SearchFooter: UIView {
    
    let label: UILabel = UILabel()
    public var searchBackgroundColor: UIColor = UIColor.blue
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configureView() {
        backgroundColor = searchBackgroundColor
        alpha = 0.0
        // Configure label
        label.textAlignment = .center
        label.textColor = UIColor.white
        addSubview(label)
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = bounds
    }
    
    //MARK: - Animation
    
    fileprivate func hideFooter() {
        UIView.animate(withDuration: 0.7) {[unowned self] in
            self.alpha = 0.0
        }
    }
    
    fileprivate func showFooter() {
        UIView.animate(withDuration: 0.7) {[unowned self] in
            self.alpha = 1.0
        }
    }
}

extension SearchFooter {
    //MARK: - Public API
    
    public func setNotFiltering() {
        label.text = ""
        hideFooter()
    }
    
    public func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
        configureView()
        if (filteredItemCount == totalItemCount) {
            setNotFiltering()
        } else if (filteredItemCount == 0) {
            label.text = "Нічого не знайдено на Ваш запит!"
            showFooter()
        } else {
            label.text = "Знайдено \(filteredItemCount) юридичних осіб із \(totalItemCount)"
            showFooter()
        }
    }
    
    public func setIsFilteringToShow1(filteredItemCount: Int, of totalItemCount: Int) {
        configureView()
        if ( totalItemCount == 0 ) {
            setNotFiltering()
        } else if (filteredItemCount == 0) {
            label.text = "Нічого не знайдено на Ваш запит!"
            showFooter()
        } else {
            label.text = "Знайдено \(filteredItemCount) юр.осіб із максимуму \(totalItemCount)"
            showFooter()
        }
    }
    
    public func setIsFilteringToShow2(rezultRasponse: String) {
        configureView()
        label.text = rezultRasponse
        showFooter()
    }
}

