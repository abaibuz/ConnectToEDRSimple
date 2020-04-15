//
//  AlertCancelOperation.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 08.10.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation
import UIKit

class AlertCancelOperation: OperationWithFinished {
    var operation: OperationWithFinished
    
    init(operation: OperationWithFinished) {
        self.operation = operation
    }
    
    override func main() {
        let alert = UIAlertController(title: "", message: "Прервать запрос?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: { _ in
            NSLog("The \"Cancel\" alert occured.")
            if !self.operation.isFinished {
               self.operation.cancel()
            }
            self.isFinished = true
        }))
        
    //    self.present(alert, animated: true, completion: nil)
        
    }
}
