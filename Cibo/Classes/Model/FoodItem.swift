//
//  FoodItem.swift
//  Cibo
//
//  Created by John Nguyen on 17/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//

// FIXME: Maybe add another item class
// to deal with a single portion or instance of an item
// food item object represent solid data: what, when, how many etc

import Foundation
import CoreData
import UIKit

// FOOD ITEM
// --------------------------------------------------------------------------
// A food item object represents a single type of food with an associated
// consumption frequency. The object is able to determine if it can be
// consumed with respect to the current consumption rate.
//
class FoodItem: NSManagedObject {
	
	// MARK: - PROPERTIES
	// ============================================================
	
	// FIXME: check correctness
	var isAvailable: Bool {
		
		if let rule = rule where !rule.currentPeriod.isExpired {
			return rule.currentPeriod.remainingEatsAllowed > 0
		}
		return true
	}
	
	
	// MARK: - INITIALIZERS
	// ============================================================
	
	convenience init(name: String, rule: Rule, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext) {
		self.init(entity: entity, insertIntoManagedObjectContext: context)
		self.name = name
		self.rule = rule
	}
	
	
	// MARK: - METHODS
	// ============================================================
	
	// DAYS SINCE LAST EATEN
	//
	func daysSinceLastEaten() -> Int? {
		// FIXME: optimize
		if let portions = portions where portions.count > 0 {
			let sortDes = NSSortDescriptor(key: "date", ascending: false)
			let sorted = portions.sortedArrayUsingDescriptors([sortDes])
			let cal = NSCalendar.currentCalendar()
			let date = cal.startOfDayForDate((sorted.first! as! Portion).date)
			let secsSince = cal.today.timeIntervalSinceDate(date)
			// days since last eaten
			return Int(secsSince / (60*60*24))
		}
		return nil
	}
	
}