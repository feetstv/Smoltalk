//
//  Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 12/11/18.
//

import Foundation

protocol SMSelectorProtocol: Hashable {
    var argumentType: SMObject.Type { get }
    var returnType: SMObject.Type { get }
    var function: SMObject.SMFunction { get }
}

public struct SMSelector: SMSelectorProtocol {
    let argumentType: SMObject.Type
    let returnType: SMObject.Type
    let function: SMObject.SMFunction
    
    public init(argumentType: SMObject.Type, returnType: SMObject.Type, function: @escaping SMObject.SMFunction) {
        self.argumentType = argumentType; self.returnType = returnType; self.function = function
    }
}

extension SMSelector {
    public var hashValue: Int {
        get { return 0 }
    }
    
    public static func == (lhs: SMSelector, rhs: SMSelector) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public enum SMError: LocalizedError {
    case UnrecognisedSelector(String, SMObject)
    case MethodReturnedNil(String, SMObject)
    case InnerExpressionReturnedNil
    case NoInitialObject(String)
    case ExpressionTooShort(String)
    case UnexpectedArgumentType(String, SMObject.Type)
    case ExpressionReturnedUnexpectedType(String, SMObject.Type)
    
    public var errorDescription: String? {
        get {
            switch self {
            case .UnrecognisedSelector(let selector, let object):
                return "[\(type(of: object)) <- \(selector)]: unrecognised selector"
            case .MethodReturnedNil(let selector, let object):
                return "[\(type(of: object)) <- \(selector)]: method returned nil"
            case .InnerExpressionReturnedNil:
                return "Inner expression returned nil, suddenly interrupting the outer expression"
            case .NoInitialObject(let object):
                return "[\(object)]: no such initial object"
            case .ExpressionTooShort(let expression):
                return "[\(expression)]: Initial object or first selector not found; expression is too short"
            case .UnexpectedArgumentType(let expression, let expectedType):
                return "[\(expression)]: Message expected argument of type \(String(describing: expectedType))"
            case .ExpressionReturnedUnexpectedType(let expression, let expectedType):
                return "[\(expression)]: Expression expected to return value of type \(String(describing: expectedType))"
            }
        }
    }
}

public protocol SMObject {
    typealias SMFunction = (SMObject?, SMObject?) throws -> SMObject?
    
    var messages: [String: SMSelector] { get }
    
    func sendMessage(_ selectorString: String, argument: SMObject?, userInfo: SMObject?) throws -> SMObject
}

extension SMObject {
    var defaultMessages: [String: SMSelector] {
        get {
            return [
                "description": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in String(describing: self) },
                "selectors": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in
                    "**Selectors**\n\(self.defaultMessages.merging(self.messages, uniquingKeysWith: { original, _ in original }).map { "- \($0.key)\($0.value.argumentType != SMNull.self ? " \($0.value.argumentType) -> \($0.value.returnType)" : $0.value.argumentType == SMAny.self ? "Any" : "")" }.sorted().joined(separator: "\n"))"
                },
                "respondsToSelector:": SMSelector(argumentType: String.self, returnType: Bool.self) { arg, _ in
                    if let selector = arg as? String {
                        return self.messages.keys.contains(selector)
                    } else { return nil }
                }
            ]
        }
    }
    
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

public struct SMNull: SMObject {
    public var messages: [String: SMSelector] = [:]
}

public struct SMAny: SMObject {
    public var messages: [String: SMSelector] = [:]
}
