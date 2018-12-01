//
//  SMSelector.swift
//  
//
//  Created by Jaesan Ryfle-Turi on 1/12/18.
//

import Foundation

fileprivate protocol SMSelectorProtocol: Hashable {
    var argumentType: SMObject.Type { get }
    var returnType: SMObject.Type { get }
    var function: SMObject.SMFunction { get }
}

public struct SMSelector: SMSelectorProtocol {
    let argumentType: SMObject.Type
    let returnType: SMObject.Type
    let function: SMObject.SMFunction
    
    public init(argumentType: SMObject.Type, returnType: SMObject.Type, function: @escaping SMObject.SMFunction) {
        self.argumentType = argumentType; self.returnType = returnType; self.function = function
    }
}

extension SMSelector {
    public var hashValue: Int {
        get { return 0 }
    }
    
    public static func == (lhs: SMSelector, rhs: SMSelector) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
