//
//  Bool+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 19/11/18.
//

import Foundation

extension Bool: SMObject {
    public var messages: [String: SMSelector] {
        get {
            return [
                "inverted": SMSelector(argumentType: SMNull.self, returnType: Bool.self) { _, _ in !self }
            ]
        }
    }
}
