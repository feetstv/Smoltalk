//
//  SMError.swift
//
//
//  Created by Jaesan Ryfle-Turi on 1/12/18.
//

import Foundation

/// Errors relating to expressions and message passing
public enum SmoltalkError: LocalizedError {
    /// Thrown when the given SMObject does not respond to the given selector
    case UnrecognisedSelector(String, MessagePassable)
    
    /// Thrown when no MessagePassable object could be found responding to a given message alias
    case UnrecognisedAlias(String)
    
    /// Thrown when an entire expression returns nil
    case ExpressionReturnedNil
    
    /// Thrown when the result of an expression involving the given SMObject and selector produces nil
    case MethodReturnedNil(String, MessagePassable)
    
    /// Thrown when an inner expression returns nil, as opposed to the outermost expression
    case InnerExpressionReturnedNil
    
    /// Thrown when the initial object (first element in the expression) does not exist
    case NoInitialObject(String)
    
    /// Thrown when the expression is too short to be evaluated. Expressions must contain at least a receiver and a selector
    case ExpressionTooShort(String)
    
    /// Thrown when an argument should have been provided, but it was not
    case ExpectedArgumentButFoundNil
    
    /// Thrown when the type of the value passed as the argument of a complex message is not the expected type
    case UnexpectedArgumentType(String, MessagePassable.Type, MessagePassable.Type)
    
    /// Thrown when the return type of the value returned from evaluating an expression is not the expected type
    case UnexpectedReturnType(MessagePassable.Type, String, MessagePassable.Type, MessagePassable.Type)
    
    /// Thrown when an unexpected error occurs
    case UnexpectedError
    
    public var errorDescription: String? {
        get {
            switch self {
            case .UnrecognisedSelector(let selector, let object):
                return "[\(type(of: object)) <- \(selector)]: unrecognised selector"
                
            case .UnrecognisedAlias(let alias):
                return "[\(alias)]: unrecognised message alias"
                
            case .ExpressionReturnedNil:
                return "Expression returned nil"
                
            case .MethodReturnedNil(let selector, let object):
                return "[\(type(of: object)) <- \(selector)]: method returned nil"
                
                
            case .InnerExpressionReturnedNil:
                return "Inner expression returned nil, suddenly interrupting the outer expression"
            case .NoInitialObject(let object):
                return "[\(object)]: no such initial object"
                
            case .ExpressionTooShort(let expression):
                return "[\(expression)]: Initial object or first selector not found; expression is too short"
                
            case .ExpectedArgumentButFoundNil:
                return "Expected argument but found nil"
                
            case .UnexpectedArgumentType(let expression, let expectedType, let returnedType):
                return "[\(expression)]: Message expected argument of type \(String(describing: expectedType)) but received \(String(describing: returnedType))"
                
            case .UnexpectedReturnType(let receiver, let expression, let expectedType, let returnedType):
                return "[\(String(describing: receiver)) \(expression)]: Expression expected to return value of type \(String(describing: expectedType)) but returned \(String(describing: returnedType))"
                
            case .UnexpectedError:
                return "Unexpected Smoltalk error"
            }
        }
    }
}
