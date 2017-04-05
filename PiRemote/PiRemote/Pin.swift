//
//  Pin.swift
//  PiRemote
//
//  Authors: Muhammad Martinez
//  Copyright (c) 2017 JLL Consulting. All rights reserved.
//

import Foundation

class Pin: NSObject, NSCoding {

    enum Types {
        case ignore, control, monitor
    }

    var _function: String = "IN"
    var function: String {
        get {
            return _function
        }
        set (newVal) {
            if type != .ignore {
                type = newVal == "IN" ? .monitor : .control
                _function = newVal
            }
        }
    }

    var id: Int = 0
    var name: String = "no name"
    var statusWhenHigh: String = "On"
    var statusWhenLow: String = "Off"
    var type: Types = .ignore
    var value: Int = 0

    convenience init(id: Int) {
        self.init()
        self.id = id
    }

    convenience init(id: Int, apiData: [String: AnyObject]) {
        let function = apiData["function"] as! String
        let value = apiData["value"] as! Int

        // Monitor pins be default
//        let type = function == "IN" ? .monitor : .control

        self.init(id: id, name: "no name", function: function, value: value)
    }


    convenience init(id: Int, name: String, function: String, value: Int,
         type: Types = .ignore, statusWhenHigh: String = "On", statusWhenLow: String = "Off") {
        self.init()
        self.function = function
        self.id = id
        self.name = name
        self.statusWhenHigh = statusWhenHigh
        self.statusWhenLow = statusWhenLow
        self.type = type
        self.value = value
    }

    // MARK: NSCoding

    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.function = decoder.decodeObject(forKey: "function") as! String
        self.id = decoder.decodeObject(forKey: "id") as! Int
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.statusWhenHigh = decoder.decodeObject(forKey: "statusWhenHigh") as! String
        self.statusWhenLow = decoder.decodeObject(forKey: "statusWhenLow") as! String
        self.type = decoder.decodeObject(forKey: "type") as! Types
        self.value = decoder.decodeObject(forKey: "value") as! Int
    }

    func encode(with coder: NSCoder) {
        coder.encode(function, forKey: "function")
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(statusWhenHigh, forKey: "statusWhenHigh")
        coder.encode(statusWhenLow, forKey: "statusWhenLow")
        coder.encode(type, forKey: "type")
        coder.encode(value, forKey: "value")
    }


    // MARK: Local Functions
//
//    func setupDefault() {
//        self.id = 0
//        self.name = "label"
//        self.statusWhenHigh = "On"
//        self.statusWhenLow = "Off"
//        self.type = .ignore
//        self.value = 0
//
//        self.function = type == .control ? "OUT" : "IN"
//    }

    func isGPIO() -> Bool {
        // TODO: Add Pi Zero

        // not GPIO on Pi B Rev 1, Pi A/B Rev 2
        _ = [1, 2, 4, 6, 9, 14, 17, 20, 25] // piOneOrTwo
        // not GPIO on Pi B+
        let piThree = [1, 2, 4, 6, 9, 14, 17, 20, 25, 27, 28, 30, 34, 39]

        // TODO: Handle other models
        return !piThree.contains(id)
    }
}
