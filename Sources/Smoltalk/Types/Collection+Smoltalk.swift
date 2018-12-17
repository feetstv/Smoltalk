//
//  Collection+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 18/11/18.
//

import Foundation

enum CollectionError: LocalizedError {
    /// Thrown when a collection does not contain objects implementing SMObject, but the expression expects to send the elements a message
    case CollectionContainsInvalidElements
    
    var errorDescription: String? {
        get {
            switch self {
            case .CollectionContainsInvalidElements:
                return "Collection's elements do not conform to MessagePassable; messages cannot be sent"
            }
        }
    }
}

extension Array: MessagePassable {
    public var messages: [String: SelectorInformation] {
        return [
            "appending:": SelectorInformation(argumentType: SMAny.self, returnType: Array.self, function: self.appending_),
            "count": SelectorInformation(argumentType: SMNull.self, returnType: Int.self, function: self.count),
            "componentsJoinedByString:": SelectorInformation(argumentType: String.self, returnType: String.self, function: self.componentsJoinedByString_),
            "map:": SelectorInformation(argumentType: String.self, returnType: Array.self, function: self.map_),
            "randomElement": SelectorInformation(argumentType: SMNull.self, returnType: SMAny.self, function: self.randomElement),
            "reversedArray": SelectorInformation(argumentType: SMNull.self, returnType: Array.self, function: self.reversedArray),
            "shuffledArray": SelectorInformation(argumentType: SMNull.self, returnType: Array.self, function: self.shuffledArray),
            "elementAtIndex:": SelectorInformation(argumentType: Int.self, returnType: SMAny.self, function: self.elementAtIndex_)
        ]
    }
    
    public var messageAliases: [String : String] { return [:] }
    
    /**
     - Parameter arg: (Object) The object to append to the array
     
     - Returns: (Array<Object>) A copy of the array containing the new element
     */
    private func appending_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        guard let object = arg as? Element else { return self }
        return self + [object]
    }
    
    /**
     - Returns: (Int) The number of elements in the array
     */
    private func count(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.count
    }
    
    /**
     - Parameter arg: (String) The string used to join the elements of the array
     
     - Returns: (String) A string containing all of the elements of the array, concatenated by the given string
     */
    private func componentsJoinedByString_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.map { String(describing: $0) }.joined(separator: arg as! String)
    }
    
    /**
     - Parameter arg: (String) A selector for a **simple** message to send to every object in the array
     
     - Returns: A new array containing the results of having sent a single, simple message to every element in the current array
     */
    private func map_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        guard let first = self.first, first is MessagePassable else { return self }
        guard let _ = self[0] as? MessagePassable else { throw CollectionError.CollectionContainsInvalidElements }
        let result = try self.map { try ($0 as! MessagePassable).sendMessage(arg as! String, argument: nil, userInfo: userInfo) }
        guard result.count > 0 else { return self }
        return result
    }
    
    /**
     - Returns: A random element from the array
     */
    private func randomElement(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        let element = self.randomElement()
        guard element != nil else { throw SmoltalkError.UnexpectedReturnType(type(of: self), "randomObject", SMAny.self, SMNull.self) }
        guard element is MessagePassable else { throw CollectionError.CollectionContainsInvalidElements }
        return element as! MessagePassable
    }
    
    /**
     - Returns: (Array<Object> A copy of the array with all the elements in reverse order
     */
    private func reversedArray(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.reversed()
    }
    
    /**
     - Returns: (Array<Object> A copy of the array with all the elements shuffled
     */
    private func shuffledArray(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.shuffled()
    }
    
    /**
     - Parameter arg: (Int) The index at which to search for and return an object
     
     - Throws: NumberError.IntOutOfBounds if the index is out of the array's bounds, or SMCollectionError.CollectionDoesNotContainSMObject if the array does not contain SMObjects (since SMFunction may only return SMObject)
     
     - Returns: (Object) The object found at the given array
     */
    private func elementAtIndex_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        guard let index = arg as? Int, index > -1, index < self.count - 1 else { throw NumberError.IntOutOfBounds(0, self.count - 1) }
        guard let element = self[index] as? MessagePassable else { throw CollectionError.CollectionContainsInvalidElements }
        return element
    }
}

extension Dictionary: MessagePassable where Key == String {
    public var messages: [String: SelectorInformation] {
        return [
            "count": SelectorInformation(argumentType: SMNull.self, returnType: Int.self, function: self.count),
            "componentsJoinedByString:": SelectorInformation(argumentType: String.self, returnType: String.self, function: self.componentsJoinedByString_),
            "keys": SelectorInformation(argumentType: SMNull.self, returnType: [String].self, function: self.keysFunction),
            "randomElement": SelectorInformation(argumentType: SMNull.self, returnType: SMAny.self, function: self.randomElement),
            "values": SelectorInformation(argumentType: SMNull.self, returnType: [MessagePassable].self, function: self.valuesFunction),
            "elementForKey:": SelectorInformation(argumentType: String.self, returnType: SMAny.self, function: self.elementForKey_)
        ]
    }
    
    public var messageAliases: [String : String] { return [:] }
    
    /**
     - Returns: (Int) The number of elements in the array
     */
    private func count(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.count
    }
    
    /**
     - Parameter arg: (String) The string used to join the elements of the array
     
     - Returns: (String) A string containing all of the elements of the array, concatenated by the given string
     */
    private func componentsJoinedByString_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.map { String(describing: $0) }.joined(separator: arg as! String)
    }
    
    /**
     - Returns: ([String]) An array containing all of the keys
     */
    private func keysFunction(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Array(self.keys)
    }
    
    /**
     - Returns: A random element from the dictionary
     */
    private func randomElement(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        let object = self.randomElement()
        guard object != nil else { throw SmoltalkError.UnexpectedReturnType(type(of: self), "randomElement", SMAny.self, SMNull.self) }
        guard object is MessagePassable else { throw CollectionError.CollectionContainsInvalidElements }
        return object as! MessagePassable
    }
    
    /**
     - Returns: ([MessagePassable]) An array containing all of the values
     */
    private func valuesFunction(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Array(self.values)
    }
    
    /**
     - Parameter arg: (String) The key used to search the dictionary for an element
     
     - Throws: NumberError.IntOutOfBounds if the index is out of the array's bounds, or SMCollectionError.CollectionDoesNotContainSMObject if the array does not contain SMObjects (since SMFunction may only return SMObject)
     
     - Returns: (Object) The object found at the given array
     */
    private func elementForKey_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        guard let element = self[arg as! String] as? MessagePassable else { throw CollectionError.CollectionContainsInvalidElements }
        return element
    }
}

