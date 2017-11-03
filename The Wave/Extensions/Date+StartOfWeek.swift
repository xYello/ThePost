//
//  Date+StartOfWeek.swift
//  The Wave
//
//  Created by Andrew Robinson on 6/15/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import Foundation

extension Date {

    struct Gregorian {
        static let calendar = Calendar(identifier: .gregorian)
    }

    var startOfWeek: Date {
        return Gregorian.calendar.date(from: Gregorian.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
}
