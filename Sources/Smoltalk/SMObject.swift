//
//  Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 12/11/18.
//

import Foundation

public protocol SMObject {
    typealias SMFunction = (SMObject?, SMObject?) throws -> SMObject?
    
    var messages: [String: SMSelector] { get }
    
    func sendMessage(_ selectorString: String, argument: SMObject?, userInfo: SMObject?) throws -> SMObject
}

extension SMObject {
    var defaultMessages: [String: SMSelector] {
        get {
            return [
                "description": SMSelector(argumentType: SMNull.self, returnType: String.self, function: self.description),
                "selectors": SMSelector(argumentType: SMNull.self, returnType: String.self, function: self.selectors),
                "respondsToSelector:": SMSelector(argumentType: String.self, returnType: Bool.self, function: self.respondsToSelector)
            ]
        }
    }
    
    private func description(arg: SMObject?, userInfo: SMObject?) throws -> SMObject? {
        return String(describing: self)
    }
    
    private func selectors(arg: SMObject?, userInfo: SMObject?) throws -> SMObject? {
        return "**Selectors**\n\(self.defaultMessages.merging(self.messages, uniquingKeysWith: { original, _ in original }).map { "- \($0.key)\($0.value.argumentType != SMNull.self ? " \($0.value.argumentType) -> \($0.value.returnType)" : $0.value.argumentType == SMAny.self ? "Any" : "")" }.sorted().joined(separator: "\n"))"
    }
    
    private func respondsToSelector(arg: SMObject?, userInfo: SMObject?) throws -> SMObject? {
        if let selector = arg as? String {
            return self.messages.keys.contains(selector)
        } else { return nil }
    }
}

extension SMObject {
    public func sendMessage(_ selectorString: String, argument: SMObject?, userInfo: SMObject?) throws -> SMObject {
        if let selectorContainer = self.defaultMessages.merging(self.messages, uniquingKeysWith: { original, _ in original }).first(where: { (selector, _) in
            selector == selectorString
        }) {
            if let attemptedArgument = argument {
                print("\(String(describing: type(of: attemptedArgument))) \(String(describing: selectorContainer.value.argumentType))")
                if selectorContainer.value.argumentType == SMNull.self || selectorContainer.value.argumentType == SMAny.self, type(of: argument) != selectorContainer.value.argumentType {
                    throw SMError.UnexpectedArgumentType(selectorString, selectorContainer.value.argumentType)
                }
            }
            
            if let result = try selectorContainer.value.function(argument, userInfo) {
                if selectorContainer.value.returnType == SMNull.self || type(of: result) == selectorContainer.value.returnType {
                    return result
                } else {
                    throw SMError.ExpressionReturnedUnexpectedType(selectorString, selectorContainer.value.returnType)
                }
            } else {
                throw SMError.MethodReturnedNil(selectorString, self)
            }
        } else {
            throw SMError.UnrecognisedSelector(selectorString, self)
        }
    }
}
