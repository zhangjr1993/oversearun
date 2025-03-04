//
//  Date+Extension.swift
//  AIRun
//
//  Created by AIRun on 20247/20.
//

import Foundation

extension NSDate {
    
    static func messageTimeString(date: Date?) -> String {
        guard let date = date else {
            return ""
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Get date components
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        // Calculate days between dates
        let daysDifference = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: now)).day ?? 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        
        // Same day - show time
        if daysDifference == 0 {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }
        
        // Yesterday
        if daysDifference == 1 {
            return "Yesterday"
        }
        
        // Within a week
        if daysDifference <= 7 {
            dateFormatter.dateFormat = "EEE"
            return dateFormatter.string(from: date)
        }
        
        // Same year
        if components.year == nowComponents.year {
            dateFormatter.dateFormat = "d-MMM"
            return dateFormatter.string(from: date)
        }
        
        // Different year
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}

extension Date {
    
    /// 
    /// - Parameter formatter: : 格式 yyyy-MM-dd/YYYY-MM-dd/HH:mm:ss/yyyy-MM-dd HH:mm:ss

    /// - Returns: description
    func onFormatterDate(formatter: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = formatter
        let dateString = dateformatter.string(from: self)
        return dateString
    }
    
    
    static func chatListTimeString(date: Date) -> String {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents(
            Set<Calendar.Component>([.year, .month, .day]), from: date )
        let nowComponents = calendar.dateComponents(
            Set<Calendar.Component>([.year, .month, .day]), from: Date())
        var str = ""
        let dateformatter = DateFormatter()
        if components.year != nowComponents.year {
            dateformatter.dateFormat = "YYYY-MM-dd"
        } else {
            let tempDay: Int = nowComponents.day!-components.day!
            if tempDay == 0 {
                dateformatter.dateFormat = "HH:mm"
                str = dateformatter.string(from: date)
            } else if(tempDay == 1) {
                str = "Yesterday"
            } else if(tempDay == 2) {
                str = "The day before yesterday"
            }else {
                dateformatter.dateFormat = "YYYY-MM-dd"
                str = dateformatter.string(from: date)
            }
        }
        return str
    }

}

//日期选择器里的
extension Date {
    var year: Int {
        return components(date: self).year!
    }
    var month: Int {
        return components(date: self).month!
    }
    var day: Int {
        return components(date: self).day!
    }
    var hour: Int {
        return components(date: self).hour!
    }
    var minute: Int {
        return components(date: self).minute!
    }
    var second: Int {
        return components(date: self).second!
    }
    func components(date: Date) -> DateComponents {
        let calendar = Calendar.current
        let componentsSet = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second])
        let components = calendar.dateComponents(componentsSet, from: date)
        return components
    }

    var daysInYear: Int {
        return (self.isLeapYear ? 366 : 365)
    }

    var isLeapYear: Bool {
        let year = self.year
        return (year%4==0 ? (year%100==0 ? (year%400==0 ? true : false) : true) : false)
    }

    /// 当前时间的月份的第一天是周几
    var firstWeekDayInThisMonth: Int {
        var calendar = Calendar.current
        let componentsSet = Set<Calendar.Component>([.year, .month, .day])
        var components = calendar.dateComponents(componentsSet, from: self)

        calendar.firstWeekday = 1
        components.day = 1
        let first = calendar.date(from: components)
        let firstWeekDay = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: first!)
        return firstWeekDay! - 1
    }
    /// 当前时间的月份共有多少天
    var totalDaysInThisMonth: Int {
        let totalDays = Calendar.current.range(of: .day, in: .month, for: self)
        return (totalDays?.count)!
    }

    /// 上个月份的此刻日期时间
    var lastMonth: Date {
        var dateComponents = DateComponents()
        dateComponents.month = -1
        let newData = Calendar.current.date(byAdding: dateComponents, to: self)
        return newData!
    }
    /// 下个月份的此刻日期时间
    var nextMonth: Date {
        var dateComponents = DateComponents()
        dateComponents.month = +1
        let newData = Calendar.current.date(byAdding: dateComponents, to: self)
        return newData!
    }

    /// 格式化时间
    ///
    /// - Parameters:
    ///   - formatter: 格式 yyyy-MM-dd/YYYY-MM-dd/HH:mm:ss/yyyy-MM-dd HH:mm:ss
    /// - Returns: 格式化后的时间 String
    func formatterDate(formatter: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = formatter
        let dateString = dateformatter.string(from: self)
        return dateString
    }

    static func appDefaultDate() -> Date {
        return "1995-01-01".toDate(formatter: "yyyy-MM-dd")
    }
}
