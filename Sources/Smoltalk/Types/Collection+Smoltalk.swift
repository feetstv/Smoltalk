//
//  Collection+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 18/11/18.
//

import Foundation

extension Array: SMObject {
    public var messages: [String: SMSelector] {
        get {
            return [
                "appending:": SMSelector(argumentType: SMAny.self, returnType: Array.self) { arg, _ in
                    if let object = arg as? Element {
                        return self + [object]
                    } else {
                        return self
                    }
                },
                "count": SMSelector(argumentType: SMNull.self, returnType: Int.self) { _, _ in self.count },
                "componentsJoinedByString:": SMSelector(argumentType: String.self, returnType: String.self) { arg, _ in
                    if let separator = arg as? String {
                        return self.map { String(describing: $0) }.joined(separator: String(separator))
                    } else {
                        return nil
                    }
                },
                "map:": SMSelector(argumentType: String.self, returnType: Array.self) { arg, userInfo in
                    if let selector = arg as? String {
                        if let first = self.first {
                            if first is SMObject {
                                let result = self.map { try? ($0 as! SMObject).sendMessage(selector, argument: nil, userInfo: userInfo) }
                                if result.count > 0 { return result } else { return nil }
                            } else { return nil }
                        } else { return nil }
                    } else {
                        return nil
                    }
                },
                "reversedArray": SMSelector(argumentType: SMNull.self, returnType: Array.self) { _, _ in self.reversed() },
                "shuffledArray": SMSelector(argumentType: SMNull.self, returnType: Array.self) { _, _ in self.shuffled() },
                "objectAtIndex:": SMSelector(argumentType: Int.self, returnType: SMAny.self) { arg, _ in
                    if let index = arg as? Int, index > -1, index < self.count - 1 {
                        return self[index] as? SMObject
                    } else if let indexString = arg as? String, let index = Int(indexString), index > -1, index < self.count - 1 {
                        return self[index] as? SMObject
                    } else { return nil }
                }
            ]
        }
    }
}
