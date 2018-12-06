//
//  Terp.swift
//  
//
//  Created by Jaesan Ryfle-Turi on 1/12/18.
//

import Foundation
import Smoltalk

enum ProgramState {
    case Running
    case ShouldQuit
}

var state = ProgramState.Running

while state == ProgramState.Running {
    print("Enter a Smoltalk expression and press Return, or type Q to quit:")
    if let input = readLine(strippingNewline: true) {
        if input.lowercased() == "q" { state = ProgramState.ShouldQuit } else {
            do {
                let result = try Runtime.evaluate(expression: input, customObjectDictionary: nil, userInfo: nil, delegate: nil)
                print("Result: \(String(describing: result))\n")
            } catch {
                if error is LocalizedError { print("Error: \((error as! LocalizedError).errorDescription ?? "")\n" ) }
                else { print("Error: \(String(describing: error))\n") }
            }
        }
    }
}

print("\nExiting Terp. Bye bye o/")
