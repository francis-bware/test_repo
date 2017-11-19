//
//  DateFormatters.swift
//  Boardingware
//
//  Created by francis gallagher on 20/04/16.
//  Copyright © 2016 Boardingware. All rights reserved.
//

import Foundation

open class DateFormatters : NSObject {
    
    static var fullDisplayFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM hh:mm a"
        return formatter
    }()
    
    static var timeThenDateFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a, EEE dd MMM yyyy"
        return formatter
    }()
    
    static var utcFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    static var birthDateFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        return formatter
    }()
    
    static var dateOnlyFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
//        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    static var timeOnlyFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
//        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return formatter
    }()
}

