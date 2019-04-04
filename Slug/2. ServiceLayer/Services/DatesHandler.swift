//
//  DatesHandler.swift
//  Talks
//
//  Created by Denis Garifyanov on 24/02/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation

class DatesHandler {

    let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)

    var generalDateFormatterToPrint: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter
    }
    var recentDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }

    func stringWithChoisedFromatter(withDate date: Date, howManyDaysMeansIsRecent: Int = 1) -> String {
        let currentDate = Date()
        let unitFlags: NSCalendar.Unit = [.minute, .hour, .day, .month, .year, .second]
        let componentsFromCurrentDate = self.gregorian?.components(unitFlags, from: currentDate)
        var offsetDay = DateComponents()
        offsetDay.day = 0 - howManyDaysMeansIsRecent
        offsetDay.minute = (componentsFromCurrentDate?.minute)! * (-1)
        offsetDay.hour = (componentsFromCurrentDate?.hour)! * (-1)
        offsetDay.second = (componentsFromCurrentDate?.second)! * (-1)
        let offsetDate = self.gregorian?.date(byAdding: offsetDay, to: currentDate, options: .init(rawValue: 0))
        if date < offsetDate! {
            return self.generalDateFormatterToPrint.string(from: date)
        }
        return self.recentDateFormatter.string(from: date)
    }

}
