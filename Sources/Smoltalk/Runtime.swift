//
//  SMRuntime.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 27/11/18.
//

import Foundation

/// The "runtime"; this class encapsulates a few enums, structs, and functions to efficiently evaluate full expressions (rather than simple messages sent to individual objects)
public class Runtime {
    static var defaultObjectDictionary: [String: MessagePassable] {
        return [
            "Bool": true,
            "Date": Date(),
            "Int": 0,
            "Double": 0.0,
            "String": ""
        ]
    }
    
    /**
     Evaluates full Smoltalk expressions. Note: use SMObject's sendMessage(_:argument:userInfo:) function to send a message to a single object.
     
     - Parameters:
     - expression: A string containing a full expression, including an initial receiver and at least one selector
     - customObjectDictionary: An optional dictionary containing a mapping of strings to instance of objects implementing SMObject suitable for use as the initial receiver
     - userInfo: An immutable object implementing SMObject that is present throughout the entire evaluation of the expression. This is readable by every SMFunction called during evaluation.
     
     - Throws: Either SMError if there was an issue with the expression, or other Errors thrown by each receiver
     
     - Returns: The resultant SMObject that comes from evaluating the expression.
     */
    public static func evaluate(expression: String, customObjectDictionary: [String: MessagePassable]?, userInfo: MessagePassable?, delegate: RuntimeDelegate?) throws -> MessagePassable {
        return try Parser.parse(tokens: Lexer.run(onMessage: expression), customObjectDictionary: customObjectDictionary, userInfo: userInfo, delegate: delegate)
    }
    
    /**
     Evaluates a partial Smoltalk expression using a message alias. Note: use SMObject's sendMessage(_:argument:userInfo:) function to send a message to a single object.
     
     - Parameters:
     - expression: A string containing a full expression, including an initial receiver and at least one selector
     - customObjectDictionary: An optional dictionary containing a mapping of strings to instance of objects implementing SMObject suitable for use as the initial receiver
     - userInfo: An immutable object implementing SMObject that is present throughout the entire evaluation of the expression. This is readable by every SMFunction called during evaluation.
     
     - Throws: Either SMError if there was an issue with the expression, or other Errors thrown by each receiver
     
     - Returns: The resultant SMObject that comes from evaluating the expression.
     */
    public static func evaluate(aliasedExpression: String, customObjectDictionary: [String: MessagePassable]?, userInfo: MessagePassable?, delegate: RuntimeDelegate?) throws -> MessagePassable {
        if let alias = aliasedExpression.components(separatedBy: " ").first {
            
            guard let match = Runtime.defaultObjectDictionary.merging(customObjectDictionary ?? [:], uniquingKeysWith: { original, new in original }).first(where: { $0.value.messageAliases.keys.contains(alias) }) else {
                throw SmoltalkError.UnrecognisedAlias(alias)
            }
            
            let fullExpression = "\(match.key) \(match.value.messageAliases[alias]!)\(aliasedExpression.components(separatedBy: " ").count > 1 ? " \(aliasedExpression.components(separatedBy: " ").dropFirst().joined(separator: " "))" : "")"
            
            return try Runtime.evaluate(expression: fullExpression, customObjectDictionary: customObjectDictionary, userInfo: userInfo, delegate: delegate)
        } else {
            throw SmoltalkError.UnexpectedError
        }
    }
    
    /**
     Parses the first component in the message string, checks if there's a matching object in the default or custom object dictionaries, determines whether the string could be converted to one of a few basic types, and returns the initial object.
     
     - Throws: SmoltalkError.NoInitialObject if a suitable object could not be found
     
     - Parameters:
     - name: The name of the initial object
     - customObjectDictionary: A dictionary of names of strings as keys, with the values being instances of objects implementing MessagePassable
     
     - Returns: An object implementing MessagePassable that matches the name parameter
     */
    private static func initialObjects(_ name: String, customObjectDictionary: [String: MessagePassable]) throws -> MessagePassable {
        return try {
            switch name {
            case "Date": return Date()
            case "String": return ""
            default:
                if let object = customObjectDictionary[name] {
                    return object
                } else {
                    if name.contains("."), let number = Double(name) { return number }
                    else if let number = Int(name) { return number }
                    else if let number = Double(name) { return number }
                    else if name.hasPrefix("\""), name.hasSuffix("\"") { return String(name.prefix(name.count - 1).suffix(name.count - 2)) }
                    else { throw SmoltalkError.NoInitialObject(name) }
                }
            }
            }()
    }
    
    enum Token {
        case InitialObject(String)
        case Selector(String)
        case ComplexSelector(String, String)
        case ComplexSelectorWithExpression(String, String)
        case InnerExpression(String)
    }
    
    struct Lexer {
        static func run(onMessage message: String, object: MessagePassable? = nil) throws -> [Token] {
            var object: MessagePassable? = object
            var components: [String] = []
            var nextToken = ""
            var writingQuote = false
            var writingInnerMessage = false
            var expectSpace = false
            var level = 0
            
            func addCharacter(_ character: Character) {
                nextToken = nextToken + String(character)
                print(nextToken)
            }
            
            let tokens = message.enumerated().reduce([Token]()) { (tokens, character) in
                print("\(character.offset): \(character.element) -> \(nextToken)")
                var appendableTokens: [Token]? = nil
                
                if character.element == ":" || character.element == "\"" {
                    print("Adding \'\(character.element)\'")
                    addCharacter(character.element)
                    if character.element == ":" {
                        // expectSpace = false
                    } else if character.element == "\"" {
                        expectSpace = true
                        writingQuote = true
                        if writingQuote, nextToken.count > 1, nextToken.hasPrefix("\""), nextToken.hasSuffix("\"") {
                            writingQuote = false
                            expectSpace = false
                            if let newTokens = append(nextToken) {
                                appendableTokens = newTokens
                                print("Found new token after colon")
                            }
                        }
                    }
                } else if character.element == "[" || character.element == "]" {
                    if character.element == "[" {
                        if !writingQuote {
                            level = level + 1
                            writingInnerMessage = true
                        }
                        expectSpace = true
                        print("Adding \'\(character.element)\'")
                        addCharacter(character.element)
                    } else if writingInnerMessage, character.element == "]" {
                        print("Adding \'\(character.element)\'")
                        addCharacter(character.element)
                        level = level - 1
                        if level == 0, nextToken.count > 1 {
                            writingInnerMessage = false
                            expectSpace = false
                            if let newTokens = append(nextToken) {
                                appendableTokens = newTokens
                                print("Found new token after bracket")
                            }
                        }
                    }
                } else if character.element == " " {
                    if expectSpace {
                        print("Adding \'\(character.element)\'")
                        addCharacter(character.element)
                        expectSpace = writingQuote || writingInnerMessage
                    } else if nextToken.count > 0 {
                        print("Next token not nil, it's \(nextToken)")
                        if let newTokens = append(nextToken) {
                            appendableTokens = newTokens
                            print("Found new token after space")
                        }
                    }
                } else {
                    print("Adding \'\(character.element)\'")
                    addCharacter(character.element)
                    if character.offset == message.count - 1, nextToken.count > 0 {
                        print("Next token not nil, it's \(nextToken)")
                        if let newTokens = append(nextToken) {
                            appendableTokens = newTokens
                            print("Found new token")
                        }
                    }
                }
                
                return tokens + (appendableTokens ?? [Token]())
            }
            
            func append(_ component: String) -> [Token]? {
                components.append(component)
                nextToken = ""
                
                if components.count > 1 {
                    if components[components.count - 1].hasSuffix(":") {
                        return nil
                    } else if components[components.count - 2].hasSuffix(":") {
                        if components[components.count - 1].hasPrefix("["), components[components.count - 1].hasSuffix("]") {
                            return [Token.ComplexSelectorWithExpression(components[components.count - 2], String(components[components.count - 1].prefix(components[components.count - 1].count - 1).suffix(components[components.count - 1].count - 2)))]
                        } else {
                            return [Token.ComplexSelector(components[components.count - 2], components[components.count - 1])]
                        }
                    } else if components[components.count - 1].hasPrefix("["), components[components.count - 1].hasSuffix("]") {
                        return [Token.InnerExpression(components[components.count - 1])]
                    } else {
                        return [Token.Selector(components[components.count - 1])]
                    }
                } else {
                    return [Token.InitialObject(components[components.count - 1])]
                }
            }
            
            guard tokens.count >= 2 else { throw SmoltalkError.ExpressionTooShort(message) }
            return tokens
        }
    }
    
    struct Parser {
        static func parse(tokens: [Token], customObjectDictionary: [String: MessagePassable]?, userInfo: MessagePassable?, delegate: RuntimeDelegate?) throws -> MessagePassable {
            var object: MessagePassable?
            
            try tokens.enumerated().forEach { token in
                switch token.element {
                case .InitialObject(let string):
                    object = try Runtime.initialObjects(string, customObjectDictionary: customObjectDictionary ?? [:])
                case .Selector(let selector):
                    object = try object?.sendMessage(selector, argument: nil, userInfo: userInfo, delegate: delegate)
                case .ComplexSelector(let selector, let argument):
                    if argument.hasPrefix("\""), argument.hasSuffix("\"") {
                        object = try object?.sendMessage(selector, argument: String(argument.prefix(argument.count - 1).suffix(argument.count - 2)), userInfo: userInfo, delegate: delegate)
                    } else {
                        object = try object?.sendMessage(selector, argument: argument, userInfo: userInfo, delegate: delegate)
                    }
                case .ComplexSelectorWithExpression(let selector, let expression):
                    let result = try Runtime.evaluate(expression: expression, customObjectDictionary: customObjectDictionary, userInfo: userInfo, delegate: delegate)
                    object = try object?.sendMessage(selector, argument: result, userInfo: userInfo, delegate: delegate)
                case .InnerExpression(let expression):
                    object = try Runtime.evaluate(expression: expression, customObjectDictionary: customObjectDictionary, userInfo: userInfo, delegate: delegate)
                }
            }
            
            guard let returnableObject = object else {
                throw SmoltalkError.ExpressionReturnedNil
            }
            return returnableObject
        }
    }
    
    /**
     Sends a message to the given receiver
     
     - Parameters:
     - selectorString: The selector to send to the object
     - receiver: The object implementing SMObject to which the message sholud be sent
     - argument: An object implementing SMObject. If the message is simple, this is automatically converted to an instance of SMNull.
     - userInfo: An immutable object implementing SMObject that is present throughout the entire evaluation of the expression. This is readable by every SMFunction called during evaluation.
     
     - Throws: Either SMError if there was an issue with the expression, or other Errors thrown by each receiver
     
     - Returns: The resultant SMObject that comes from evaluating the expression.
     */
    public static func sendMessage(_ selectorString: String, toReceiver receiver: MessagePassable, argument: MessagePassable?, userInfo: MessagePassable?, delegate: RuntimeDelegate? = nil) throws -> MessagePassable {
        // Merge the default messages with the object's own messages, giving priority to the defaults
        // Get the SMSelector associated with a given selector
        if let selectorContainer = receiver.defaultMessages.merging(receiver.messages, uniquingKeysWith: { original, _ in original }).first(where: { (selector, _) in
            selector == selectorString
        }) {
            var usableArgument: MessagePassable? = nil
            
            if let attemptedArgument = argument {
                if selectorContainer.value.argumentType != SMNull.self, selectorContainer.value.argumentType != SMAny.self, selectorContainer.value.argumentType != type(of: attemptedArgument) {
                    // Last ditch effort to convert strings to numbers
                    var converted: MessagePassable? = nil
                    if selectorContainer.value.argumentType == Int.self {
                        if attemptedArgument is String { converted = Int(attemptedArgument as! String) }
                    } else if selectorContainer.value.argumentType == Double.self {
                        if attemptedArgument is Int { converted = Double(attemptedArgument as! Int) }
                        else if attemptedArgument is String { converted = Double(attemptedArgument as! String) }
                    }
                    
                    if let attemptedConversion = converted {
                        usableArgument = attemptedConversion
                        print("Notice: converted \(type(of: attemptedArgument)) to \(selectorContainer.value.argumentType)")
                    } else if selectorContainer.value.argumentType != type(of: attemptedArgument){
                        throw SmoltalkError.UnexpectedArgumentType(selectorString, selectorContainer.value.argumentType, type(of: attemptedArgument))
                    }
                } else {
                    usableArgument = attemptedArgument
                }
            }
            
            // Evaluate!
            let error = delegate?.canRunFunction(selectorContainer.value, userInfo: userInfo)
            guard error == nil else { throw error! }
            let result = try selectorContainer.value.function(usableArgument ?? SMNull.standard, userInfo)
            if selectorContainer.value.returnType == SMNull.self || selectorContainer.value.returnType == SMAny.self || type(of: result) == selectorContainer.value.returnType {
                return result
            } else {
                throw SmoltalkError.UnexpectedReturnType(type(of: receiver), selectorString, selectorContainer.value.returnType, type(of: result))
            }
        } else {
            throw SmoltalkError.UnrecognisedSelector(selectorString, receiver)
        }
    }
}

public protocol RuntimeDelegate {
    func canRunFunction(_ selectorInformation: SelectorInformation, userInfo: MessagePassable?) -> Error?
}
