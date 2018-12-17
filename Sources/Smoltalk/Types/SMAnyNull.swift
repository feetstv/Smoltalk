//
//  Bool+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 19/11/18.
//

import Foundation

public struct SMNull: MessagePassable {
    public static var standard: SMNull = SMNull()
    private init() { }
    
    public var messages: [String: SelectorInformation] = [:]
    public var messageAliases: [String : String] = [:]
}

public struct SMAny: MessagePassable {
    
    public static var standard: SMAny = SMAny()
    private init() { }
    public var messages: [String: SelectorInformation] = [:]
    public var messageAliases: [String : String] = [:]
}
