//
//  OperationWithFinished.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 23.10.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation

class OperationWithFinished : Operation {
    var currentState : Bool = false
    
    override var isFinished: Bool {
        get {
            return currentState
        }
        set(newValue) {
            willChangeValue(forKey: "isFinished")
            currentState = newValue
            didChangeValue(forKey: "isFinished")
        }
        
    }
    
    override func cancel() {
        super.cancel()
        self.isFinished = true
    }
}
