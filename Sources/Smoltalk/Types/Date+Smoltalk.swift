//
//  Date+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 18/11/18.
//

import Foundation

extension Date: MessagePassable {
    public var messages: [String: SelectorInformation] {
        get {
            return [
                "dateAddingTimeInterval:": SelectorInformation(argumentType: Double.self, returnType: Date.self, function: self.dateAddingTimeInterval_),
                "dateFromString:": SelectorInformation(argumentType: String.self, returnType: Date.self, function: self.dateFromString_),
                "day": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.day),
                "dayOfWeekInMonth": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.dayOfWeekInMonth),
                "month": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.month),
                "quarter": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.quarter),
                "year": SelectorInformation(argumentType: SMNull.self, returnType: String.self, function: self.quarter),
                "today": SelectorInformation(argumentType: SMNull.self, returnType: Date.self, function: self.today),
                "stringWithFormat:": SelectorInformation(argumentType: String.self, returnType: String.self, function: self.stringWithFormat_),
                "timeIntervalSince1970": SelectorInformation(argumentType: SMNull.self, returnType: Int.self, function: self.timeIntervalSince1970Function),
                "timeIntervalSinceReferenceDate": SelectorInformation(argumentType: SMNull.self, returnType: Int.self, function: self.timeIntervalSinceReferenceDateFunction),
                "timeIntervalSinceDate": SelectorInformation(argumentType: Date.self, returnType: Int.self, function: self.timeIntervalSinceDate_)
            ]
        }
    }
    
    private func dateAddingTimeInterval_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.addingTimeInterval(arg as! Double)
    }
    
    private func dateFromString_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter.date(from: arg as! String)!
    }
    
    private func day(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.dateString(.Day)
    }
    
    private func dayOfWeekInMonth(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.dateString(.DayOfWeekInMonth)
    }
    
    private func month(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.dateString(.Month)
    }
    
    private func quarter(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.dateString(.Quarter)
    }
    
    private func year(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.dateString(.Year)
    }
    
    private func today(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Date()
    }
    
    private func stringWithFormat_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        let formatter = DateFormatter()
        formatter.dateFormat = arg as? String
        return formatter.string(from: self)
    }
    
    private func timeIntervalSince1970Function(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.timeIntervalSince1970
    }
    
    private func timeIntervalSinceReferenceDateFunction(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.timeIntervalSinceReferenceDate
    }
    
    private func timeIntervalSinceDate_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.timeIntervalSince(arg as! Date)
    }

    
    fileprivate enum DateFormat: String {
        case Day = "EEEE"
        case DayOfWeekInMonth = "F"
        case Month = "MMMM"
        case Quarter = "QQQQ"
        case Year = "yyyy"
    }
    
    fileprivate func dateString(_ format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_NZ")
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}
