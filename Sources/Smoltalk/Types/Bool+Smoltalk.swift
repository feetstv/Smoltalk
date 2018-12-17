//
//  Bool+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 19/11/18.
//

import Foundation

extension Bool: MessagePassable {
    public var messages: [String: SelectorInformation] {
        return [
            "invertedBool": SelectorInformation(argumentType: SMNull.self, returnType: Bool.self, function: self.inverted),
            "intValue": SelectorInformation(argumentType: SMNull.self, returnType: Int.self, function: self.intValue)
        ]
    }
    
    public var messageAliases: [String : String] { return [:] }
    
    /**
     - Returns: (Bool) The opposite value of the current boolean: true if false, false if true
     */
    private func inverted(arg: MessagePassable?, userInfo: MessagePassable?) throws -> MessagePassable {
        return !self
    }
    
    /**
     - Returns: (Int) An integer representing the boolean value: 0 if false, 1 if true
     */
    private func intValue(arg: MessagePassable?, userInfo: MessagePassable?) throws -> MessagePassable {
        return self == true ? 1 : 0
    }
}
