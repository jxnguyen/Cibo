//
//  AddItemViewController.swift
//  Cibo
//
//  Created by John Nguyen on 22/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//

import UIKit
import CoreData

class AddItemViewController: UITableViewController {

	// MARK: - PROPERTIES & OUTLETS
	// ============================================================
	
	@IBOutlet weak var nameTF: UITextField!
	@IBOutlet weak var frequencyPK : UIPickerView!
	
	var moc: NSManagedObjectContext!
	
	let times: [String] = {
		var arr = ["once", "twice"]
		for i in 3...10 {
			arr.append(String(i))
		}
		return arr
	}()
	
	let days: [String] = {
		var arr = ["a day"]
		for i in 2...14 {
			arr.append("\(i) days")
		}
		return arr
	}()
	
	// MARK: - STANDARD
	// ============================================================
	
	// VIEW DID LOAD
	//
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.backgroundColor = UIColor.whiteColor()
		
    }
	
	// MEMORY WARNING
	//
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	// MARK: - ACTIONS
	// ============================================================
	
	// DONE
	//
	@IBAction func done() {
		
		let foodEntity = NSEntityDescription.entityForName("FoodItem", inManagedObjectContext: moc)
		let item = FoodItem(entity: foodEntity!, insertIntoManagedObjectContext: moc)
		
		let ruleEntity = NSEntityDescription.entityForName("Rule", inManagedObjectContext: moc)
		let rule = Rule(entity: ruleEntity!, insertIntoManagedObjectContext: moc)
		rule.times = frequencyPK.selectedRowInComponent(0) + 1
		rule.days = frequencyPK.selectedRowInComponent(1) + 1
		rule.isStrict = true
		rule.isActive = true
		rule.foodItem = item
		rule.renewCurrentPeriod()
		
		// FIXME: validate
		item.name = nameTF.text!
		item.rule = rule

		do {
			try moc.save()
		}
		catch let error as NSError {
			print("Error saving: \(error)")
		}
		
		navigationController?.popViewControllerAnimated(true)
	}
	
	// CANCEL
	//
	@IBAction func cancel() {
		
	}
	
}

// MARK: - TABLE VIEW DELEGATE
// ============================================================
extension AddItemViewController {
	
	// HEIGHT FOR ROW
	//
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		switch (indexPath.section, indexPath.row) {
		// name row
		case (0,0):
			return 60
		// picker
		case (0,2):
			return 120
		default:
			return 44
		}
	}
}

// MARK: - PICKER VIEW DATA SOURCE / DELEGATE
// ============================================================
extension AddItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	
	// NUMBER OF COMPONENTS
	//
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 2
	}
	
	// NUMBER OF ROWS IN COMPONENT
	//
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return component == 0 ? times.count : days.count
	}
	
	// TITLE FOR ROW
	//
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return component == 0 ? times[row] : days[row]
	}
}
