//
//  Numbers+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 18/11/18.
//

import Foundation

extension Int: SMObject {
    public var messages: [String: SMSelector] {
        get {
            return [
                "doubled": SMSelector(argumentType: SMNull.self, returnType: Double.self) { _, _ in (self * 2) },
                "halved": SMSelector(argumentType: SMNull.self, returnType: Double.self) { _, _ in (self > 0 ? self / 2 : nil) },
                "adding:": SMSelector(argumentType: SMAny.self, returnType: Double.self) { arg, _ in
                    if let string = arg as? String, let number = Double(string) { return Double(self) + number } else { return nil }
                },
                "subtracting:": SMSelector(argumentType: SMAny.self, returnType: Double.self) { arg, _ in
                    if let string = arg as? String, let number = Double(string) { return Double(self) - number } else { return nil }
                },
                "multipliedBy:": SMSelector(argumentType: SMAny.self, returnType: Double.self) { arg, _ in
                    if let string = arg as? String, let number = Double(string) { return Double(self) * number } else { return nil }
                },
                "dividedBy:": SMSelector(argumentType: SMAny.self, returnType: Double.self) { arg, _ in
                    if let string = arg as? String, let number = Double(string) { return Double(self) / number } else { return nil }
                },
                "squareRoot": SMSelector(argumentType: SMNull.self, returnType: Double.self) { _, _ in Double(self).squareRoot() }
            ]
        }
    }
}

extension Double: SMObject {
    public var messages: [String: SMSelector] {
        get {
            return [
                "doubled": SMSelector(argumentType: SMNull.self, returnType: Double.self) { _, _ in (self * 2) },
                "halved": SMSelector(argumentType: SMNull.self, returnType: Double.self) { _, _ in (self > 0 ? self / 2 : nil) },
                "adding:": SMSelector(argumentType: SMAny.self, returnType: Double.self) { arg, _ in
                    if let string = arg as? String, let number = Double(string) { return Double(self) + number } else { return nil }
                },
                "subtracting:": SMSelector(argumentType: SMAny.self, returnType: Double.self) { arg, _ in
                    if let string = arg as? String, let number = Double(string) { return Double(self) - number } else { return nil }
                },
                "multipliedBy:": SMSelector(argumentType: SMAny.self, returnType: Double.self) { arg, _ in
                    if let string = arg as? String, let number = Double(string) { return Double(self) * number } else { return nil }
                },
                "dividedBy:": SMSelector(argumentType: SMAny.self, returnType: Double.self) { arg, _ in
                    if let string = arg as? String, let number = Double(string) { return Double(self) / number } else { return nil }
                },
                "squareRoot": SMSelector(argumentType: SMNull.self, returnType: Double.self) { _, _ in Double(self).squareRoot() }
            ]
        }
    }
}
