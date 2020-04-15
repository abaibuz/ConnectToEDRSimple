//
//  ShowDataFromEDR.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 29.09.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation
import UIKit

class ShowDataFromEDR: OperationWithFinished {
     var table: UITableView!
     var filteredImemsCount: Int
     var totalItemCount: Int
     var searchFooter: SearchFooter!
     var statusFinishOperation: StatusFinishGetDataOperation = .ok
     var cancelView: UIView!
    
    init(table: UITableView, filteredImemsCount: Int, totalItemCount: Int, searchFooter: SearchFooter, statusFinishOperation: StatusFinishGetDataOperation, cancelView: UIView) {
        self.table = table
        self.filteredImemsCount = filteredImemsCount
        self.totalItemCount = totalItemCount
        self.searchFooter = searchFooter
        self.statusFinishOperation = statusFinishOperation
        self.cancelView = cancelView
    }
    
    override func main() {
        DispatchQueue.main.async {
            self.receiveResponseServerEDR(sattusOperation: self.statusFinishOperation)
            self.table.reloadData()
        }
        self.isFinished = true
    }
    
    func receiveResponseServerEDR(sattusOperation: StatusFinishGetDataOperation) {
        let superviewFrame = self.table.frame
        self.table.tableFooterView = nil
        self.table.tableHeaderView?.frame = self.searchFooter.frame
        self.table.tableHeaderView = self.searchFooter
        switch sattusOperation {
        case .ok:
                self.searchFooter.setIsFilteringToShow1(filteredItemCount: self.filteredImemsCount, of: self.totalItemCount)
        case .cancel:
            self.table.tableHeaderView = nil
            if let cancelView = self.cancelView {
                cancelView.frame = superviewFrame
                self.table.tableFooterView = cancelView
            }
            else {
                self.table.tableFooterView = nil
            }
        case .badrequest:
            self.searchFooter.setIsFilteringToShow2( rezultRasponse : "Невірно побудовано запит до ЄДР")
        case .createdresponse:
            self.searchFooter.setIsFilteringToShow2( rezultRasponse : "Запит виконано, але дані не отримані!")
        case .forbidden:
            self.searchFooter.setIsFilteringToShow2( rezultRasponse : "Доступ до ЄДР заборонено!")
        case .notfound:
            self.searchFooter.setIsFilteringToShow2( rezultRasponse : "Сайт ЄДР не знайдено! Перевірте Інтернет!")
        case .servererror:
            self.searchFooter.setIsFilteringToShow2( rezultRasponse : "Помилка сервера ЄДР!")
        case .unknown:
            self.searchFooter.setIsFilteringToShow2( rezultRasponse : "Невідома помилка!")
        case .encodeurl:
            self.searchFooter.setIsFilteringToShow2( rezultRasponse : "Невірний адрес (URL) запиту до ЄДР!")
        case .nilresponse:
            self.searchFooter.setIsFilteringToShow2( rezultRasponse : "Порожній заголовок відповіді сервера ЄДР!")
        case .nodata:
            self.searchFooter.setIsFilteringToShow2( rezultRasponse : "Порожня відповідь сервера ЄДР!")
        case .errordecode:
            self.searchFooter.setIsFilteringToShow2( rezultRasponse : "Помилка при декодуванні даних з сервера ЄДР!")
        }
    }
    
}
