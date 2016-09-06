//
//  NSCalendar+dayUnits.swift
//  Cibo
//
//  Created by John Nguyen on 21/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//
//
//	DESCRIPTION
//	====================================================================
//
//	Some useful extension to NSCalendar.
//
//	====================================================================


import Foundation

extension NSCalendar {
	
	// TODAY
	// -----------------------------------------------------------
	// Returns an NSDate object configure to the start of the
	// current day.
	//
	var today: NSDate {
		return NSCalendar.currentCalendar().startOfDayForDate(NSDate())
	}
	
	// NEXT DAY AFTER DATE
	// -----------------------------------------------------------
	// Returns the following day of a given date.
	//
	func nextDayAfterDate(date: NSDate) -> NSDate {
		return dateByAddingUnit(.Day,
		                        value: 1,
		                        toDate: date,
		                        options: NSCalendarOptions.init(rawValue: 0))!
	}

	// IS DATE IN PERIOD
	// -----------------------------------------------------------
	// Returns true if given day falls within start & end dates of
	// the given period.
	//
	func isDate(date: NSDate, inPeriod period: Rule.Period) -> Bool {
		let isBeforeEnd = date.compare(period.endDate) == .OrderedAscending
		let isSameDayAsEnd = isDate(date, inSameDayAsDate: period.endDate)
		return isBeforeEnd || isSameDayAsEnd
	}
}