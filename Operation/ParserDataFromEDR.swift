//
//  ParserDataFromEDR.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 29.09.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import Foundation

class ParserDataFromEDR: OperationWithFinished {
    var firms: edrFirms!
    var data: Data?
    var error: Error?
    var statusFinishOperation : StatusFinishGetDataOperation = .ok

    override func main() {
        var json = """
                    """.data(using: .utf8)
        let suff = """
                    {
                      "firms":
                    """.data(using: .utf8)
        json?.append(suff!)
        
        if let data = self.data {
            json?.append(data)
            let pref = """
                        }
                        """.data(using: .utf8)
            json?.append(pref!)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { (decoder) -> Date in
                return try self.decodeDateRFC(decoder: decoder)
            }
            self.statusFinishOperation = .errordecode
            self.firms = try! decoder.decode(edrFirms.self, from: json!)
            
 //           dump(self.firms)
        } else {
            self.statusFinishOperation = .nodata
        }
        
        self.statusFinishOperation = .ok
        self.isFinished = true
        
    }
    
    func decodeDateRFC(decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)
        let endOfSentence = dateStr.firstIndex(of: ".")!
        let firstSentence = dateStr[...endOfSentence] as NSString
        let dateStr1 = firstSentence.replacingOccurrences(of: ".", with: "Z")
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = RFC3339DateFormatter.date(from: dateStr1) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr1)")
        }
        return date
    }
    
}
