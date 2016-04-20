//
//  Extension+UIDatePicker.swift
//  share-food
//
//  Created by macbook on 20/05/2019.
//  Copyright © 2019 Invision-040. All rights reserved.
//

import Foundation

extension Date {
    var nearest15:Date{
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        // Round down to nearest date:
        let ceilMinute = minute + 15 - (minute % 15)
        //ceilMinute = ceilMinute == 60 ? 59: ceilMinute
        let ceilDate = calendar.date(bySettingHour: ceilMinute == 60 ? hour + 1 : hour,
                                     minute: ceilMinute == 60 ? 0 : ceilMinute,
                                      second: 0,
                                      of: self) ?? self
        return ceilDate
    }
    // returns current date by adding time zone difference
    static func currentDate() -> Date{
        var date = Date()
        let timeZone = TimeZone.current
        date = date.addingTimeInterval( TimeInterval(timeZone.secondsFromGMT()) )
        return date
    }
    
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear (date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameDay  (date: Date) -> Bool { isEqual(to: date, toGranularity: .day) }
    func isInSameWeek (date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    var isInThisYear:  Bool { isInSameYear(date: Date()) }
    var isInThisMonth: Bool { isInSameMonth(date: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(date: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}

extension Date{
    func toStringwith(format:String, timezone:TimeZone? = nil)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timezone
        return dateFormatter.string(from: self)
    }
    func toStringUTCwith(format:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        return dateFormatter.string(from: self)
    }
}

extension String{
 
    func converToString(fromFormat:String = "yyyy-MM-dd'T'HH:mm:ss" ,toFormat:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        guard var date = dateFormatter.date(from: self) else {return ""}
        dateFormatter.dateFormat = toFormat
        date = date.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
        return dateFormatter.string(from: date)
    }
    
    func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss")-> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        var date = dateFormatter.date(from: self)
        let intervalDiff = TimeInterval(TimeZone.current.secondsFromGMT())
        date = date?.addingTimeInterval(intervalDiff)
        return date
    }
}

extension Date {
    func timeAgo(numericDates: Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest =  self > now ? self : now

        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfMonth, .month, .year, .second]
        let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)

        let year = components.year ?? 0
        let month = components.month ?? 0
        let weekOfMonth = components.weekOfMonth ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0

        switch (year, month, weekOfMonth, day, hour, minute, second) {
            case (let year, _, _, _, _, _, _) where year >= 2: return "\(year) years ago"
            case (let year, _, _, _, _, _, _) where year == 1 && numericDates: return "1 year ago"
            case (let year, _, _, _, _, _, _) where year == 1 && !numericDates: return "Last year"
            case (_, let month, _, _, _, _, _) where month >= 2: return "\(month) months ago"
            case (_, let month, _, _, _, _, _) where month == 1 && numericDates: return "1 month ago"
            case (_, let month, _, _, _, _, _) where month == 1 && !numericDates: return "Last month"
            case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth >= 2: return "\(weekOfMonth) weeks ago"
            case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth == 1 && numericDates: return "1 week ago"
            case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth == 1 && !numericDates: return "Last week"
            case (_, _, _, let day, _, _, _) where day >= 2: return "\(day) days ago"
            case (_, _, _, let day, _, _, _) where day == 1 && numericDates: return "1 day ago"
            case (_, _, _, let day, _, _, _) where day == 1 && !numericDates: return "Yesterday"
            case (_, _, _, _, let hour, _, _) where hour >= 2: return "\(hour) hours ago"
            case (_, _, _, _, let hour, _, _) where hour == 1 && numericDates: return "1 hour ago"
            case (_, _, _, _, let hour, _, _) where hour == 1 && !numericDates: return "An hour ago"
            case (_, _, _, _, _, let minute, _) where minute >= 2: return "\(minute) minutes ago"
            case (_, _, _, _, _, let minute, _) where minute == 1 && numericDates: return "1 minute ago"
            case (_, _, _, _, _, let minute, _) where minute == 1 && !numericDates: return "A minute ago"
            case (_, _, _, _, _, _, let second) where second >= 3: return "\(second) seconds ago"
            default: return "Just now"
        }
    }
}
