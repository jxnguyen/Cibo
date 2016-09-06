//
//  CalendarView.swift
//  Cibo
//
//  Created by John Nguyen on 05/09/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//

import Foundation
import UIKit

class CalendarView: UIView {
	
	@IBOutlet weak var menuView: JTCalendarMenuView!
	@IBOutlet weak var contentView: JTHorizontalCalendarView!
	
	var manager = JTCalendarManager()
	
	var todayDate = NSDate()
	var minDate: NSDate?
	var maxDate: NSDate?
	var dateSelected: NSDate?
	
	
	// INSTANCE FROM NIB
	//
	class func instanceFromNib() -> CalendarView {
		let nib = UINib(nibName: "CalendarView", bundle: nil)
		return nib.instantiateWithOwner(nil, options: nil)[0] as! CalendarView
	}
}
