//
//  ItemDetailViewController.swift
//  Cibo
//
//  Created by John Nguyen on 17/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//

// TODO: Adjust model & update labels
// TODO: Cancel button only if adding item
// TODO: if itemtoedit, top right edit button
// TODO: enable save only if textfield not empty
// TODO: keyboard return button
// TODO: strip trailing spaces from name before save

import UIKit


class ItemDetailViewController: UITableViewController {
	
	// MARK: - PROPERTIES & OUTLETS
	// ============================================================
	
	@IBOutlet weak var nameLB: UILabel!
	@IBOutlet weak var ruleLB: UILabel!
	@IBOutlet weak var periodDatesLB: UILabel!
	@IBOutlet weak var periodStatsLB: UILabel!
	
	var item: FoodItem!
	
	lazy var dateFormatter: NSDateFormatter = {
		let df = NSDateFormatter()
		df.dateStyle = .MediumStyle
		df.timeStyle = .NoStyle
		return df
	}()
	
	
	// MARK: - STANDARD
	// ============================================================
	
	// VIEW DID LOAD
	//
    override func viewDidLoad() {
        super.viewDidLoad()
		updateLabels()
	}
	
	// MEMORY WARNING
	//
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - HELPERS
	// ============================================================

	// UPDATE LABELS
	//
	func updateLabels() {
		
		nameLB.text = item.name
		
		if let rule = item.rule {
			ruleLB.text = rule.stringDescription
			let period = rule.currentPeriod
			let str1 = dateFormatter.stringFromDate(period.startDate)
			let str2 = dateFormatter.stringFromDate(period.endDate)
			periodDatesLB.text = str1 + " - " + str2
			periodStatsLB.text = "\(period.count) eaten, \(period.remainingEatsAllowed) remaining"
		}
		else {
			ruleLB.text = "freely"
			periodDatesLB.text = "N/A"
			periodStatsLB.text = "N/A"
		}
	}
	
}
