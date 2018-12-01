//
//  Bool+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 19/11/18.
//

import Foundation

public struct SMNull: SMObject {
    public var messages: [String: SMSelector] = [:]
}

public struct SMAny: SMObject {
    public var messages: [String: SMSelector] = [:]
}
