//
//  Portion.swift
//  Cibo
//
//  Created by John Nguyen on 26/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//

import Foundation
import CoreData


class Portion: NSManagedObject {
	
	@NSManaged private var mealType: Int16
	
	// enum wrapper
	var meal: MealType {
		get {
			return MealType(rawValue: Int(mealType))!
		}
		set {
			mealType = Int16(newValue.rawValue)
		}
	}

}

enum MealType: Int {
	case Breakfast = 0
	case Lunch = 1
	case Dinner = 2
	case Snack = 3
	
	func printable() -> String {
		switch self {
		case .Breakfast:
			return "Breakfast"
		case .Lunch:
			return "Lunch"
		case .Dinner:
			return "Dinner"
		case .Snack:
			return "Snack"
		}
	}
}