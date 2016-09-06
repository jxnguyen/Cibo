//
//  Rule.swift
//  Cibo
//
//  Created by John Nguyen on 23/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//

import Foundation
import CoreData



// Rule
// ----------------------------------------------------------------------
// Represents the allowed consumption rate of a food item, namely
// the amount of times within a certain number of days.
//
class Rule: NSManagedObject {
	
	// MARK: - ADDITIONAL PROPERTIES
	// ============================================================
	
	@NSManaged private var periodStartDate: NSDate
	@NSManaged private var periodEndDate: NSDate
	@NSManaged private var periodCount: Int16
	
	// encapsulate period data
	struct Period {
		
		var startDate: NSDate
		var endDate: NSDate
		
		var isExpired: Bool {
			let cal = NSCalendar.currentCalendar()
			return !cal.isDate(NSDate(), inPeriod: self)
		}
		
		var count: Int16
		var remainingEatsAllowed: Int16 {
			return ruleAmount - count
		}
		
		private var ruleAmount: Int16
		
		init(rule: Rule) {
			startDate = rule.periodStartDate
			endDate = rule.periodEndDate
			count = rule.periodCount
			ruleAmount = rule.times
		}
	}
	
	// FIXME: tidy up
	var currentPeriod: Period {
		get {
			let period = Period(rule: self)
			if period.isExpired {
				renewCurrentPeriod()
				return Period(rule: self)
			} else {
				return period
			}
		}
		set {
			periodStartDate = newValue.startDate
			periodEndDate = newValue.endDate
			periodCount = newValue.count
		}
	}

	
	var stringDescription: String {
		let timesStr = times == 1 ? "once" : "\(times) times"
		let daysStr = days == 1 ? "a day" : "every \(days) days"
		return timesStr + " " + daysStr
	}
	
	// MARK: - INITIALIZERS
	// ============================================================
	
	convenience init(times: Int16, days: Int16, entity: NSEntityDescription, context: NSManagedObjectContext?) {
		self.init(entity: entity, insertIntoManagedObjectContext: context)
		self.times = times
		self.days = days
		self.isStrict = true
		renewCurrentPeriod()
	}
	
	// MARK: - METHODS
	// ============================================================
	
	// RENEW CURRENT PERIOD
	//
	func renewCurrentPeriod() {
		periodCount = 0
		// end date is inclusive
		let cal = NSCalendar.currentCalendar()
		periodStartDate = cal.today
		periodEndDate = cal.dateByAddingUnit(.Day,
		                                     value: days - 1,
		                                     toDate: periodStartDate,
		                                     options: NSCalendarOptions.init(rawValue: 0))!
	}
}