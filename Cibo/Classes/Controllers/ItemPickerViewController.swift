//
//  ItemPickerViewController.swift
//  Cibo
//
//  Created by John Nguyen on 26/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//


import UIKit
import CoreData

protocol ItemPickerViewControllerDelegate: class {
	// DID FINISH PICKING FOR MEAL
	func itemPickerViewController(picker: ItemPickerViewController, didFinishPickingItems items: [FoodItem], forMealType mealType: MealType)
}


class ItemPickerViewController: UIViewController {
	
	// MARK: - PROPERTIES & OUTLETS
	// ============================================================
	
	@IBOutlet weak var tableView: UITableView!
	
	var moc: NSManagedObjectContext!
	weak var delegate: ItemPickerViewControllerDelegate?
	
	var mealType: MealType!
	var items: [FoodItem]!
	var selectedItems = [FoodItem]()
	
	let mealTypes = ["Breakfast", "Lunch", "Dinner"]
	
	// MARK: - STANDARD
	// ============================================================
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// fetch all items
		let request = NSFetchRequest(entityName: "FoodItem")
		let sortDes = NSSortDescriptor(key: "name",
		                               ascending: true,
		                               selector: #selector(NSString.localizedStandardCompare(_:)))
		
		request.sortDescriptors = [sortDes]
		
		do {
			items = try moc.executeFetchRequest(request) as! [FoodItem]
			tableView.reloadData()
		}
		catch let error as NSError {
			print("Couldn't fetch \(error), \(error.userInfo)")
		}
		
	}
	
	// MARK: - ACTIONS
	// ============================================================
	
	// DONE
	//
	@IBAction func done() {
		delegate?.itemPickerViewController(self, didFinishPickingItems: selectedItems, forMealType: mealType)
	}
	
	
}

// MARK: - TABLE VIEW DATASOURCE/DELEGATE
// ============================================================
extension ItemPickerViewController: UITableViewDataSource, UITableViewDelegate {
	
	// NUMBER OF ROWS
	//
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	// CELL FOR ROW
	//
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath)
		let item = items[indexPath.row]
		cell.textLabel?.text = item.name
		cell.detailTextLabel!.text = item.isAvailable ? "Available" : "Can't Eat!"
		cell.accessoryType = selectedItems.contains(item) ? .Checkmark : .None
		return cell
	}
	
	// DID SELECT ROW
	//
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let item = items[indexPath.row]
		let cell = tableView.cellForRowAtIndexPath(indexPath)
		// if item already selected
		if let index = selectedItems.indexOf(item) {
			selectedItems.removeAtIndex(index)
			cell?.accessoryType = .None
		} else {
			selectedItems.append(item)
			cell?.accessoryType = .Checkmark
		}
		
	}
}

// MARK: - PICKER VIEW DATA SOURCE / DELEGATE
// ============================================================
extension ItemPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	
	// NUMBER OF COMPONENTS
	//
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	// NUMBER OF ROWS IN COMPONENT
	//
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 3
	}
	
	// TITLE FOR ROW
	//
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return mealTypes[row]
	}
}

