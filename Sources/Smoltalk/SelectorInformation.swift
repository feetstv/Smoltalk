//
//  SMSelector.swift
//  
//
//  Created by Jaesan Ryfle-Turi on 1/12/18.
//

import Foundation

/**
 A type alias for the function that is executed if an SMObject responds to a message
 
 - Throws: Any error that is thrown within the function. Usually not an SMError, as those are typically thrown by SMRuntime or SMObject's sendMessage(_:arg:userInfo)
 
 - Returns: The result of executing the function, always an object implementing SMObject
*/
public typealias Function = (MessagePassable, MessagePassable?) throws -> MessagePassable

fileprivate protocol SelectorProtocol: Hashable {
    var argumentType: MessagePassable.Type { get }
    var returnType: MessagePassable.Type { get }
    var function: Function { get }
}

/// This object describes the selector's typing and also either contains or points to the Function associated with a selector
public class SelectorInformation: SelectorProtocol {
    let argumentType: MessagePassable.Type
    let returnType: MessagePassable.Type
    let function: Function
    
    /**
     - Parameters:
        - argumentType: The type of any object that implements MessagePassable, class or struct, that should be passed in as an argument to a complex message
        - returnType: The expected type of the object implementing MessagePassable that will be returned by the function
        - function: The Function that is executed if the object responds to the message associated with the selector
     */
    public init(argumentType: MessagePassable.Type, returnType: MessagePassable.Type, function: @escaping Function) {
        self.argumentType = argumentType; self.returnType = returnType; self.function = function
    }
}

extension SelectorInformation {
    public var hashValue: Int {
        get { return 0 }
    }
    
    public static func == (lhs: SelectorInformation, rhs: SelectorInformation) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
