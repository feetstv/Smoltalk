//
//  Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 12/11/18.
//

import Foundation

/// Every object that should support receiving messages must conform to the MessagePassable protocol.
public protocol MessagePassable {
    /** A dictionary representing the messages to which the object will respond.
     The key is a string. The value is an instance of Selector, which includes the Function that gets executed
     */
    var messages: [String: SelectorInformation] { get }
    
    func sendMessage(_ selectorString: String, argument: MessagePassable?, userInfo: MessagePassable?, delegate: RuntimeDelegate?) throws -> MessagePassable
}

extension MessagePassable {
    /// The default messages to which **all** objects that implement MessagePassable respond
    var defaultMessages: [String: SelectorInformation] {
        get {
            return [
                "description": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.description),
                "selectors": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.selectors),
                "respondsToSelector:": SelectorInformation(argumentType: String.self, returnType: Bool.self, function: self.respondsToSelector),
            ]
        }
    }
    
    /**
     - Returns: A string describing the object, same as Swift's String(describing: object)
     */
    private func description(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return String(describing: self)
    }
    
    /**
     - Returns: A string listing all of the receiver's selectors to which it responds
     */
    private func selectors(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return "**Selectors**\n\(self.defaultMessages.merging(self.messages, uniquingKeysWith: { original, _ in original }).map { "- \($0.key)\($0.value.argumentType != SMNull.self ? " \($0.value.argumentType)" : $0.value.argumentType == SMAny.self ? "Any" : "") \($0.value.returnType != SMNull.self ? "-> \($0.value.returnType)" : $0.value.returnType == SMAny.self ? "Any" : "")" }.sorted().joined(separator: "\n"))"
    }
    
    /**
     - Parameter arg: A selector
     
     - Returns: A boolean describing whether or not the receiver responds to a given selector.
     */
    private func respondsToSelector(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.messages.keys.contains(arg as! String)
    }
}

extension MessagePassable {
    /**
     Sends a message to the object. Internally, this calls SMRuntime.sendMessage(_:toReceiver:argument:userInfo:)
     
     - Parameters:
     - selectorString: The selector to send to the object
     - argument: An object implementing MessagePassable. If the message is simple, this is automatically converted to an instance of SMNull.
     - userInfo: An immutable object implementing MessagePassable that is present throughout the entire evaluation of the expression. This is readable by every Function called during evaluation.
     
     - Throws: Either SmoltalkError if there was an issue with the expression, or other Errors thrown by each receiver
     
     - Returns: The resultant MessagePassable that comes from evaluating the expression.
     */
    public func sendMessage(_ selectorString: String, argument: MessagePassable?, userInfo: MessagePassable?, delegate: RuntimeDelegate? = nil) throws -> MessagePassable {
        // This function actually just passes off to SMRuntime internally
        return try Runtime.sendMessage(selectorString, toReceiver: self, argument: argument, userInfo: userInfo, delegate: delegate)
    }
}
