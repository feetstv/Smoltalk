//
//  String+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 19/11/18.
//

import Foundation

extension String: SMObject {
    public var messages: [String: SMSelector] {
        get {
            return [
                "capitalisedString": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in self.capitalized },
                "capitalizedString": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in self.capitalized },
                "lowercaseString": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in self.lowercased() },
                "ransomNoteString": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in self.enumerated().map { $0.offset % 2 == 0 ? String($0.element).uppercased() : String($0.element).lowercased() }.joined() },
                "reversedString": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in String(self.reversed()) },
                "stringWithSwitchedCase": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in self.map { String($0).uppercased() == String($0) ? String($0).lowercased() : String($0).uppercased() }.joined() },
                "characters": SMSelector(argumentType: SMNull.self, returnType: [String].self) { _, _ in self.map { String($0) } },
                "componentsSeparatedByString:": SMSelector(argumentType: String.self, returnType: [String].self) { arg, _ in
                        if let string = arg as? String {
                            return self.components(separatedBy: string)
                        } else { return nil }
                },
                "uppercaseString": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in self.uppercased() }
            ]
        }
    }
}
