//
//  String+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 19/11/18.
//

import Foundation

extension String: MessagePassable {
    public var messages: [String: SelectorInformation] {
        get {
            return [
                "capitalizedString": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.capitalizedString),
                "lowercaseString": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.lowercaseString),
                "ransomNoteString": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.ransomNoteString),
                "reversedString": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.reversedString),
                "characters": SelectorInformation(argumentType: SMNull.self, returnType: [String].self, function: self.characters),
                "componentsSeparatedByString:": SelectorInformation(argumentType: String.self, returnType: [String].self, function: self.componentsSeparatedByString_),
                "uppercaseString": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.uppercaseString)
            ]
        }
    }
    
    /**
     - Returns: (String) A capitalized copy of the string
     */
    private func capitalizedString(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.capitalized
    }
    
    /**
     - Returns: (String) A lower-case copy of the string
     */
    private func lowercaseString(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.lowercased()
    }
    
    /**
     - Returns: (String) A copy of the string with every letter alternating between upper- and lower-case
     */
    private func ransomNoteString(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.enumerated().map { $0.offset % 2 == 0 ? String($0.element).uppercased() : String($0.element).lowercased() }.joined()
    }
    
    /**
     - Returns: (String) A copy of the string with the characters in reverse order
     */
    private func reversedString(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return String(self.reversed())
    }
    
    /**
     - Returns: ([String]) An array containing the characters of the string
     */
    private func characters(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.map { String($0) }
    }
    
    /**
     - Returns: ([String]) An array consisting of substrings taken from the string, separated by the given string
     */
    private func componentsSeparatedByString_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.components(separatedBy: arg as! String)
    }
    
    /**
     - Returns: (String) An upper-case copy of the string
     */
    private func uppercaseString(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.uppercased()
    }
}
