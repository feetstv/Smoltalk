//
//  Date+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 18/11/18.
//

import Foundation

extension Date: MessagePassable {
    public var messages: [String: SelectorInformation] {
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
    
    public var messageAliases: [String : String] {
        return [
            "day": "day",
            "month": "month",
            "year": "year",
            "epochtime": "timeIntervalSince1970"
        ]
    }
    
    /**
     - Parameter arg: (Double) The number of seconds to add to the date. Subtract seconds by using a negative value.
     
     - Returns: (Date) The date resulting from the calculation
     */
    private func dateAddingTimeInterval_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.addingTimeInterval(arg as! Double)
    }
    
    /**
     - Parameter arg: (String) The date string, conforming to the following NSDateFormatter format: "yyyy-MM-dd HH:mm:ss Z"
     
     - Throws: SmoltalkError.ExpressionReturnedNil if no Date object could be constructed from the given date string
     
     - Returns: (Date) A Date object constructed from the given date string
     */
    private func dateFromString_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        guard let returnableDate = formatter.date(from: arg as! String) else {
            throw SmoltalkError.ExpressionReturnedNil
        }
        return returnableDate
    }
    
    /**
     - Returns: (String) The name of the day based on the default locale.
     */
    private func day(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.dateString(.Day)
    }
    
    /**
     - Returns: (String) The day of the week in the month based on the default locale.
     */
    private func dayOfWeekInMonth(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.dateString(.DayOfWeekInMonth)
    }
    
    /**
     - Returns: (String) The name of the month based on the default locale.
     */
    private func month(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.dateString(.Month)
    }
    
    /**
     - Returns: (String) The name of the current quarter based on the default locale.
     */
    private func quarter(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.dateString(.Quarter)
    }
    
    /**
     - Returns: (String) The year based on the current locale. Convert the year to a number using String's intValue selector.
     */
    private func year(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.dateString(.Year)
    }
    
    /**
     - Returns: (Date) The current date.
     */
    private func today(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return Date()
    }
    
    /**
     - Parameter arg: (String) An NSDateFormat format string.
     
     - Returns: (String) A string representation of the date using the given format string.
     */
    private func stringWithFormat_(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        let formatter = DateFormatter()
        formatter.dateFormat = arg as? String
        return formatter.string(from: self)
    }
    
    /**
     - Returns: (Int) The number of seconds elapsed between 1 January 1970 and the current date.
     */
    private func timeIntervalSince1970Function(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.timeIntervalSince1970
    }
    
    /**
     - Returns: (Int) The number of seconds elapsed between 1 January 2000 and the current date.
     */
    private func timeIntervalSinceReferenceDateFunction(arg: MessagePassable, userInfo: MessagePassable?) throws -> MessagePassable {
        return self.timeIntervalSinceReferenceDate
    }
    
    /**
     - Parameter arg: (Date) The date from which to calculate the number of elapsed seconds.
     
     - Returns: (Int) The number of seconds elapsed between the given date and the current date.
     */
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
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}
