//
//  QueryToEDR.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 21.12.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation
import UIKit

class QueryToEDR {
    var firms: edrFirms!
    var tempUrl: String = "http://edr.data-gov-ua.org/api/companies?where={\"Field\":{\"contains\":\"Content\"}}&limit=countRecord&skip=startRecord&sort=id"
    var feildName: String = "edrpou"
    var countR: String = "1"
    var startR: String = "0"
    var getDataQueue = OperationQueue()
    let loadDataQueue = DispatchQueue(label: "com.ConnectToEDR.getData")
    var statusFinishOperation: StatusFinishGetDataOperation = .ok
    let progressHUD = ProgressHUD(text: "Перервати")
    var view: UIView! = nil
    
    init(feildName: String, countR: String, startR: String, view: UIView) {
        self.feildName = feildName
        self.countR = countR
        self.startR = startR
        self.view = view
    }

    public func executeQuery(textForSearch: String!) {
        let urlText = self.tempUrl as NSString;
        let url1 = urlText.replacingOccurrences(of: "Field", with: feildName) as NSString
        //--111111111
        if let textForSearch = textForSearch {
            let url2 = url1.replacingOccurrences(of: "Content", with: textForSearch) as NSString

            let url3 = url2.replacingOccurrences(of: "countRecord", with: countR) as NSString
            let url4 = url3.replacingOccurrences(of: "startRecord", with: startR) as NSString
            
            //-222222222222
            loadDataQueue.sync {
  //          loadDataQueue.async {
                let getDataFromEDR = GetDataFromEDR(url: url4 as String)
                
                DispatchQueue.main.async{
                    self.view.addSubview(self.progressHUD)
                    self.progressHUD.operation = getDataFromEDR
   //                 self.setUserInteractionEnabled(isUserInteractionEnabled: false, alpha: 0.7)
                    self.progressHUD.show()
                }
                
                let parserDataFromEDR = ParserDataFromEDR()
                let fetchOperation = BlockOperation() {
                    DispatchQueue.main.async {
                        self.progressHUD.hide()
                        self.progressHUD.removeFromSuperview()
      //                  self.setUserInteractionEnabled(isUserInteractionEnabled: true, alpha: 1)
                    }
                    
                    self.statusFinishOperation = getDataFromEDR.statusFinishOperation
                    
                    if self.statusFinishOperation == .ok {
                        if let data = getDataFromEDR.data {
                            parserDataFromEDR.data = data
                            parserDataFromEDR.error = getDataFromEDR.error
                        }
                        else {
                                self.statusFinishOperation = .nodata
                        }
                    }
                    else {
                        if self.firms != nil {
                            self.firms.firms.removeAll()
                        }
                    }
                }
                //-333333
                let finishOperation = BlockOperation() {
                    if self.statusFinishOperation == .ok {
                        if let firms =  parserDataFromEDR.firms {
                            self.firms = firms
                        }
                        else {
                                self.statusFinishOperation = parserDataFromEDR.statusFinishOperation
                        }
                    }
                }
                //-333333
                
                fetchOperation.addDependency(getDataFromEDR)
                parserDataFromEDR.addDependency(fetchOperation)
                finishOperation.addDependency(parserDataFromEDR)
                self.getDataQueue.addOperations([getDataFromEDR, fetchOperation, parserDataFromEDR,finishOperation], waitUntilFinished: true)
            }
            //-222222
        }
        //-111111
    }
  
  
}
