//
//  SMRuntime.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 27/11/18.
//

import Foundation

public class SMRuntime {
    public static func processExpression(_ expression: String, customObjectDictionary: [String: SMObject]?, userInfo: SMObject?) throws -> SMObject? {
        return try SMParser.parse(tokens: SMLexer.run(onMessage: expression), customObjectDictionary: customObjectDictionary, userInfo: userInfo)
    }
    
    private static func initialObjects(_ name: String, customObjectDictionary: [String: SMObject]) throws -> SMObject? {
        return try {
            switch name {
            case "Date": return Date()
            case "String": return ""
            default:
                print(customObjectDictionary.keys)
                if let object = customObjectDictionary[name] {
                    print("Found")
                    return object
                } else {
                    if name.contains("."), let number = Double(name) { return number }
                    else if let number = Int(name) { return number }
                    else if name.hasPrefix("\""), name.hasSuffix("\"") { return String(name.prefix(name.count - 1).suffix(name.count - 2)) }
                    else { throw SMError.NoInitialObject(name) }
                }
            }
            }()
    }
    
    public enum SMToken {
        case InitialObject(String)
        case Selector(String)
        case ComplexSelector(String, String)
        case ComplexSelectorWithExpression(String, String)
        case InnerExpression(String)
    }
    
    public struct SMLexer {
        public static func run(onMessage message: String, object: SMObject? = nil, components: [String] = [], nextToken: String? = nil, writingQuote: Bool = false, writingInnerMessage: Bool = false, expectSpace: Bool = false, level: Int = 0) throws -> [SMToken] {
            var object: SMObject? = object
            var components = components
            var nextToken = nextToken
            var writingQuote = writingQuote
            var writingInnerMessage = writingInnerMessage
            var expectSpace = expectSpace
            var level = level
            
            func addCharacter(_ character: Character) {
                nextToken = (nextToken ?? "") + String(character)
            }
            
            let tokens = message.enumerated().reduce([SMToken]()) { (tokens, character) in
                var appendableTokens: [SMToken]? = nil
                
                if character.element == ":" || character.element == "\"" {
                    addCharacter(character.element)
                    if character.element == ":" {
                        // expectSpace = false
                    } else if character.element == "\"" {
                        expectSpace = true
                        writingQuote = true
                        if writingQuote, let quote = nextToken, quote.count > 1, quote.hasPrefix("\""), quote.hasSuffix("\"") {
                            writingQuote = false
                            expectSpace = false
                            if let newTokens = append(quote) {
                                appendableTokens = newTokens
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
                        addCharacter(character.element)
                    } else if writingInnerMessage, character.element == "]" {
                        addCharacter(character.element)
                        level = level - 1
                        if level == 0, nextToken != nil {
                            writingInnerMessage = false
                            expectSpace = false
                            if let newTokens = append(nextToken!) {
                                appendableTokens = newTokens
                            }
                        }
                    }
                } else if character.element == " " {
                    if expectSpace {
                        addCharacter(character.element)
                        expectSpace = writingQuote || writingInnerMessage
                    } else if nextToken != nil {
                        if let newTokens = append(nextToken!) {
                            appendableTokens = newTokens
                        }
                    }
                } else {
                    addCharacter(character.element)
                    if character.offset == message.count - 1, nextToken != nil {
                        if let newTokens = append(nextToken!) {
                            appendableTokens = newTokens
                        }
                    }
                }
                
                return tokens + (appendableTokens ?? [SMToken]())
            }
            
            func append(_ component: String) -> [SMToken]? {
                components.append(component)
                nextToken = nil
                
                if components.count > 1 {
                    if components[components.count - 1].hasSuffix(":") {
                        return nil
                    } else if components[components.count - 2].hasSuffix(":") {
                        if components[components.count - 1].hasPrefix("["), components[components.count - 1].hasSuffix("]") {
                            return [SMToken.ComplexSelectorWithExpression(components[components.count - 2], String(components[components.count - 1].prefix(components[components.count - 1].count - 1).suffix(components[components.count - 1].count - 2)))]
                        } else {
                            return [SMToken.ComplexSelector(components[components.count - 2], components[components.count - 1])]
                        }
                    } else if components[components.count - 1].hasPrefix("["), components[components.count - 1].hasSuffix("]") {
                        return [SMToken.InnerExpression(components[components.count - 1])]
                    } else {
                        return [SMToken.Selector(components[components.count - 1])]
                    }
                } else {
                    return [SMToken.InitialObject(components[components.count - 1])]
                }
            }
            
            guard tokens.count >= 2 else { throw SMError.ExpressionTooShort(message) }
            return tokens
        }
    }
    
    public struct SMParser {
        static func parse(tokens: [SMToken], customObjectDictionary: [String: SMObject]?, userInfo: SMObject?) throws -> SMObject {
            var object: SMObject?
            
            try tokens.enumerated().forEach { token in
                switch token.element {
                case SMToken.InitialObject(let string):
                    object = try SMRuntime.initialObjects(string, customObjectDictionary: customObjectDictionary ?? [:])
                case SMToken.Selector(let selector):
                    object = try object?.sendMessage(selector, argument: nil, userInfo: userInfo)
                case SMToken.ComplexSelector(let selector, let argument):
                    if argument.hasPrefix("\""), argument.hasSuffix("\"") {
                        object = try object?.sendMessage(selector, argument: String(argument.prefix(argument.count - 1).suffix(argument.count - 2)), userInfo: userInfo)
                    } else {
                        object = try object?.sendMessage(selector, argument: argument, userInfo: userInfo)
                    }
                case SMToken.ComplexSelectorWithExpression(let selector, let expression):
                    let result = try SMRuntime.processExpression(expression, customObjectDictionary: customObjectDictionary, userInfo: userInfo)
                    object = try object?.sendMessage(selector, argument: result, userInfo: userInfo)
                case SMToken.InnerExpression(let expression):
                    object = try SMRuntime.processExpression(expression, customObjectDictionary: customObjectDictionary, userInfo: userInfo)
                }
            }
            
            return object!
        }
    }
}
