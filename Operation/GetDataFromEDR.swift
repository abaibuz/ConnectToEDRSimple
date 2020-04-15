//
//  GetDataFromEDR.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 29.09.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//
import Foundation
import UIKit

class GetDataFromEDR: OperationWithFinished {
    var url: String?
    var data: Data?
    var error: Error?
    var statusFinishOperation : StatusFinishGetDataOperation = .ok

    init(url: String) {
        self.url = url
    }
    
    override func cancel() {
        self.isFinished = true
    }
    
    override func main() {
        guard let URL = URL(string: self.url!.encodeUrl) else {
                self.statusFinishOperation = .encodeurl
                self.isFinished = true
                return
        }
        let session = URLSession.shared
        
        let task = session.dataTask(with: URL) {(data,response,error) in
            if let response = response {
                let response1 = response as! HTTPURLResponse
                switch  response1.statusCode {
                    case 200:
                      self.statusFinishOperation = .ok
                    case 400:
                      self.statusFinishOperation = .badrequest
                    case 201:
                      self.statusFinishOperation = .createdresponse
                    case 403:
                      self.statusFinishOperation = .forbidden
                    case 404:
                     self.statusFinishOperation = .notfound
                    default:
                      self.statusFinishOperation = .unknown
                }
            } else {
  //              self.statusFinishOperation = .nilresponse
                self.statusFinishOperation = .notfound
                self.isFinished = true
                return
            }
            
            if self.statusFinishOperation != .ok {
                self.isFinished = true
                return
            }
            
            guard let data = data
            else {
                self.statusFinishOperation = .nodata
                self.isFinished = true
                return
            }
  //          print(data)
            self.statusFinishOperation = .ok
            self.data = data
            self.error = error
            self.isFinished = true
        }
        
        task.resume()
        
    }

}
