//
//  Date+Smoltalk.swift
//  Smoltalk
//
//  Created by Jaesan Ryfle-Turi on 18/11/18.
//

import Foundation

extension Date: SMObject {
    public var messages: [String: SMSelector] {
        get {
            return [
                "dateByAddingTimeInterval:": SMSelector(argumentType: Double.self, returnType: Date.self) { arg, _ in
                    if let timeInterval = arg as? Double {
                        return self.addingTimeInterval(timeInterval)
                    } else {
                        return nil
                    }
                },
                "dateFromString:": SMSelector(argumentType: String.self, returnType: Date.self) { arg, _ in
                    if let dateString = arg as? String {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                        return formatter.date(from: dateString)
                    } else {
                        return nil
                    }
                },
                "day": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in self.dateString(.Day)
                },
                "dayOfWeekInMonth": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in self.dateString(.DayOfWeekInMonth)
                },
                "month": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in self.dateString(.Month)
                },
                "quarter": SMSelector(argumentType: SMNull.self, returnType: String.self) { _, _ in self.dateString(.Quarter)
                },
                "stringWithFormat:": SMSelector(argumentType: String.self, returnType: String.self) { arg, _ in
                    if let dateFormat = arg as? String {
                        let formatter = DateFormatter()
                        formatter.dateFormat = dateFormat
                        return formatter.string(from: self)
                    } else {
                        return nil
                    }
                },
                "timeIntervalSince1970": SMSelector(argumentType: SMNull.self, returnType: Int.self) { _, _ in self.timeIntervalSince1970
                },
                "timeIntervalSinceReferenceDate": SMSelector(argumentType: SMNull.self, returnType: Int.self) { _, _ in self.timeIntervalSinceReferenceDate
                }
            ]
        }
    }
    
    enum DateFormat {
        case Day
        case DayOfWeekInMonth
        case Month
        case Quarter
    }
    
    func dateString(_ format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_NZ")
        formatter.dateFormat = format == .Day ? "EEEE" : format == .DayOfWeekInMonth ? "F" : format == .Month ? "MMMM" : "QQQQ"
        return formatter.string(from: self)
    }
}
