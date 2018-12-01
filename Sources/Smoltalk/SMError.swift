//
//  SMError.swift
//  
//
//  Created by Jaesan Ryfle-Turi on 1/12/18.
//

import Foundation

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
