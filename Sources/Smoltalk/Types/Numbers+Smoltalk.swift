//
//  Numbers+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 18/11/18.
//

import Foundation

enum NumberError: LocalizedError {
    /// Thrown when a numerical argument to SMObject.sendMessage(_:arg:userInfo) is expected to be between two bounds
    case IntOutOfBounds(Int, Int)
}

fileprivate protocol SMNumber {
    func adding_(arg: MessagePassable?, userInfo: MessagePassable?) throws -> MessagePassable
    func subtracting_(arg: MessagePassable?, userInfo: MessagePassable?) throws -> MessagePassable
    func multipliedBy_(arg: MessagePassable?, userInfo: MessagePassable?) throws -> MessagePassable
    func dividedBy_(arg: MessagePassable?, userInfo: MessagePassable?) throws -> MessagePassable
    func squareRoot(arg: MessagePassable?, userInfo: MessagePassable?) throws -> MessagePassable
    func doubleValue(arg: MessagePassable?, userInfo: MessagePassable?) throws -> MessagePassable
    func intValue(arg: MessagePassable?, userInfo: MessagePassable?) throws -> MessagePassable
}

extension Int: MessagePassable {
    public var messages: [String: SelectorInformation] {
        return [
            "adding:": SelectorInformation(argumentType: Double.self, returnType: Double.self, function: self.adding_),
            "doubleValue": SelectorInformation(argumentType: SMNull.self, returnType: Double.self, function: self.doubleValue),
            "subtracting:": SelectorInformation(argumentType: Double.self, returnType: Double.self, function: self.subtracting_),
            "multipliedBy:": SelectorInformation(argumentType: Double.self, returnType: Double.self, function: self.multipliedBy_),
            "dividedBy:": SelectorInformation(argumentType: Double.self, returnType: Double.self, function: self.dividedBy_),
            "squareRoot": SelectorInformation(argumentType: SMNull.self, returnType: Double.self, function: self.squareRoot)
        ]
    }
    
    public var messageAliases: [String : String] { return [:] }
    
    /**
     - Parameter arg: (Double) The number to add to the current value
     
     - Returns: (Double) The result of the calculation
     */
    private func adding_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Double(self) + (arg as! Double)
    }
    
    /**
     - Returns: (Double) The value of the Int expressed as a Double
     */
    private func doubleValue(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Double(self)
    }
    
    /**
     - Parameter arg: (Double) The number to subtract from the current value
     
     - Returns: (Double) The result of the calculation
     */
    private func subtracting_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Double(self) - (arg as! Double)
    }
    
    /**
     - Parameter arg: (Double) The number by which to divide the current value
     
     - Returns: (Double) The result of the calculation
     */
    private func dividedBy_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Double(self) / (arg as! Double)
    }
    
    /**
     - Parameter arg: (Double) The number by which to multiply the current value
     
     - Returns: (Double) The result of the calculation
     */
    private func multipliedBy_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Double(self) * (arg as! Double)
    }
    
    /**
     - Returns: (Double) The square root of the integer
     */
    private func squareRoot(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Double(self).squareRoot()
    }
}

extension Double: MessagePassable {
    public var messages: [String: SelectorInformation] {
        return [
            "adding:": SelectorInformation(argumentType: Double.self, returnType: Double.self, function: self.adding_),
            "intValue": SelectorInformation(argumentType: SMNull.self, returnType: Int.self, function: self.intValue),
            "subtracting:": SelectorInformation(argumentType: Double.self, returnType: Double.self, function: self.subtracting_),
            "multipliedBy:": SelectorInformation(argumentType: Double.self, returnType: Double.self, function: self.multipliedBy_),
            "dividedBy:": SelectorInformation(argumentType: Double.self, returnType: Double.self, function: self.dividedBy_),
            "squareRoot": SelectorInformation(argumentType: SMNull.self, returnType: Double.self, function: self.squareRoot)
        ]
    }
    
    public var messageAliases: [String : String] { return [:] }
    
    /**
     - Parameter arg: (Double) The number to add to the current value
     
     - Returns: (Double) The result of the calculation
     */
    private func adding_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self + (arg as! Double)
    }
    
    /**
     - Returns: (Int) The value of the Double expressed as an Int (rounding down)
     */
    private func intValue(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Int(self)
    }
    
    /**
     - Parameter arg: (Double) The number to subtract from the current value
     
     - Returns: (Double) The result of the calculation
     */
    private func subtracting_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self - (arg as! Double)
    }
    
    /**
     - Parameter arg: (Double) The number by which to divide the current value
     
     - Returns: (Double) The result of the calculation
     */
    private func dividedBy_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self / (arg as! Double)
    }
    
    /**
     - Parameter arg: (Double) The number by which to multiply the current value
     
     - Returns: (Double) The result of the calculation
     */
    private func multipliedBy_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self * (arg as! Double)
    }
    
    /**
     - Returns: (Double) The square root of the integer
     */
    private func squareRoot(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.squareRoot()
    }
}
