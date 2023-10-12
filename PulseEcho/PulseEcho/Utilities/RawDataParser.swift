//
//  RawDataParser.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-27.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import EventCenter

typealias PARSING_RESPONSE  = (_ response : Any, _ type: ResponseType) -> Void

enum ResponseType: String {
    case Empty = "Empty"
    case Unknown = "Unknown"
    case CoreObject = "CoreObject"
    case SensorObject = "SensorObject"
    case HeightObject = "HeightObject"
    case IndentifierObejct = "IndentifierObejct"
    case VerticalMoveObject = "VerticalMoveObject"
    case DataStringObject = "DataStringObject"
    case CountsObject = "CountsObject"
}

class RawDataParse {
    
    var rawData: [String: Any]
    var identifier: String = ""
    var rawString: String = ""
    var corruptedData: Bool = false
    
    init(raw: String, ec: EventCenter? = nil) {
        var _rawData = [String:Any]()
        guard !raw.isEmpty else {
            rawData = [:]
            return
        }
        let _string: String = raw.replacingOccurrences(of: "Header", with: "")
        
        let _filtered = Utilities.instance.filterRawData(raw: _string, char: ["~"])
        var _str = _filtered.split(separator: "|")
        _str.remove(at: 0)
        
        if _string.contains("S1|"){
            _rawData[ResponseType.CoreObject.rawValue] = CoreObject(raw:_filtered,  strings: _str, ec: ec)
            identifier = ResponseType.CoreObject.rawValue

        }
        
        if _string.contains("S2|") {
            _rawData[ResponseType.SensorObject.rawValue] = SensorObject(raw:_filtered, strings: _str, ec: ec)
            identifier = ResponseType.SensorObject.rawValue
        }
        
        if _string.contains("S3|") {
            _rawData[ResponseType.HeightObject.rawValue] = HeightObject(raw:_filtered, strings: _str, ec: ec)
            identifier = ResponseType.HeightObject.rawValue

        }
        
        if _string.contains("S4|") {
            _rawData[ResponseType.DataStringObject.rawValue] = DataStringObject(raw:_filtered, strings: _str, ec: ec)
            identifier = ResponseType.DataStringObject.rawValue
        }
        
        if _string.contains("S5|") {
            _rawData[ResponseType.IndentifierObejct.rawValue] = IdentifierObject(raw:_filtered, strings: _str, ec: ec)
            identifier = ResponseType.IndentifierObejct.rawValue
        }
        
        if _string.contains("S6|") {
            _rawData[ResponseType.CountsObject.rawValue] = CountsObject(raw:_filtered, strings: _str, ec: ec)
            identifier = ResponseType.CountsObject.rawValue
        }
        
        if _string.contains("VM|") {
            let vmRawStr = Utilities.instance.filterRawData(raw: _filtered, char: ["V","M"])
            _rawData[ResponseType.VerticalMoveObject.rawValue] = VerticalMoveObject(rawString: _filtered, strings: _str, ec: ec, raw: vmRawStr, notify: true)
            identifier = ResponseType.VerticalMoveObject.rawValue
        }
        
        
        self.rawString = _string
        self.rawData = _rawData
    }
}
