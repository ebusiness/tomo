//
//  ExNSDate.swift
//  Tomo
//
//  Created by starboychina on 2015/08/10.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

private let formatter = DateFormatter()

extension Date {
    
    func monthDays () -> Int { return Calendar.current.range(of: .day, in: .month, for: self)!.count }
    
    func toString(dateStyle style: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short, doesRelativeDateFormatting: Bool = false) -> String
    {
        formatter.dateStyle = style
        formatter.timeStyle = timeStyle
        formatter.doesRelativeDateFormatting = doesRelativeDateFormatting
        return formatter.string(from: self)
    }
    
    func relativeTimeToString() -> String
    {
        let time = self.timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970
        
//        NSLocalizedString("just now", comment: "relative time")
        
        let seconds = now - time
        if seconds < 10 {
            return "刚刚"
        } else if seconds < 60 {
            return "\(Int(seconds)) 秒前"
        }
        
        let minutes = round(seconds/60)
        if minutes < 60 {
            if minutes == 1 {
                return "1 分钟前"
            } else {
                return "\(Int(minutes)) 分钟前"
            }
        }
        
        let hours = round(minutes/60)
        if hours < 24 {
            return "\(Int(hours)) 小时前"
        }
        
        let days = round(hours/24)
        if days < 7 {
            return "\(Int(days)) 天前"
        }
        
        let weeks = round(days/7)
        if weeks < 4 {
            return "\(Int(weeks)) 周前"
        }
        
        if Int(days) < self.monthDays() {
            return "1个月前"
        }
        
        let months = floor(days/30)
        
        if months < 12 {
            return "\(Int(months))个月前"
        }
        
        let years = floor(months/12)
        
        return "\(Int(years))年前"
    }
}

