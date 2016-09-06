//
//  TodayViewController.swift
//  Cibo
//
//  Created by John Nguyen on 18/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//

// TODO: Optimize picked items management (dont delete all etc)
// TODO: Check table loading counts

import UIKit
import CoreData

class TodayViewController: UITableViewController {
	
	// MARK: - PROPERTIES & OUTLETS
	// ============================================================
	
	var moc: NSManagedObjectContext!
	
	var mealControllers = [NSFetchedResultsController]()
	var calendarView: CalendarView!
	
	
	// MARK: - STANDARD
	// ============================================================
	
	// VIEW DID LOAD
	//
    override func viewDidLoad() {
        super.viewDidLoad()
		
		do {
			for i in 0...2 {
				mealControllers.append(controllerForMealType(i))
				try mealControllers[i].performFetch()
			}
		}
		catch let error as NSError {
			print("Could not fetch \(error), \(error.userInfo)")
		}
		
		// instantiate calendar view
		calendarView = CalendarView.instanceFromNib()
		calendarView.bounds.size.height = 360
		calendarView.manager.delegate = self
		calendarView.manager.menuView = calendarView.menuView
		calendarView.manager.contentView = calendarView.contentView
		calendarView.manager.setDate(NSDate())
		// add as header view to table
		tableView.tableHeaderView = calendarView
		
		
		// register section header
		let nib = UINib(nibName: "MealSectionHeaderView", bundle: nil)
		tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "SectionHeader")
	}
	
	// MEMORY WARNING
	//
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// PREPARE FOR SEGUE
	//
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if segue.identifier == "ItemPickerSegue" {
			let picker = segue.destinationViewController as! ItemPickerViewController
			picker.moc = moc
			picker.mealType = MealType(rawValue: sender as! Int)
			
			// consumed items for selected meal
			let meal = mealControllers[sender as! Int]
			let currPortions = meal.fetchedObjects! as! [Portion]
			picker.selectedItems = currPortions.map { $0.foodItem }
			picker.delegate = self
		}
		else if segue.identifier == "ItemDetailSegue" {
			let vc = segue.destinationViewController as! ItemDetailViewController
			let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
			let meal = mealControllers[indexPath.section]
			let index = NSIndexPath(forRow: indexPath.row, inSection: 0)
			vc.item = (meal.objectAtIndexPath(index) as! Portion).foodItem
		}
	}

	
	// MARK: - TABLE VIEW DATA SOURCE
	// ============================================================
	
	// NUMBER OF SECTIONS
	//
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return mealControllers.count
	}
	
	// NUMBER OF ROWS
	//
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return mealControllers[section].fetchedObjects!.count
	}
	
	// CELL FOR ROW
	//
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath)
		
		let index = NSIndexPath(forRow: indexPath.row, inSection: 0)
		let meal = mealControllers[indexPath.section]
		let portion = meal.objectAtIndexPath(index) as! Portion
		cell.textLabel!.text = portion.foodItem.name

		return cell
	}
	
	// MARK: - TABLE VIEW DELEGATE
	// ============================================================
	
	// VIEW FOR HEADER IN SECTION
	//
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("SectionHeader") as! MealSectionHeaderView
		header.titleLabel.text = MealType(rawValue: section)!.printable().uppercaseString
		header.section = section
		header.delegate = self
		return header
	}
	
	// HEIGHT FOR HEADER IN SECTION
	//
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 55
	}
	
	
	// MARK: - HELPERS
	// ============================================================

	// CONTROLLER FOR MEAL TYPE
	//
	func controllerForMealType(type: Int) -> NSFetchedResultsController {
		// get meals for today
		let startOfToday = NSCalendar.currentCalendar().today
		let startOfTomorrow = NSCalendar.currentCalendar().nextDayAfterDate(startOfToday)
		
		let request = NSFetchRequest(entityName: "Portion")
		let predicate = NSPredicate(format: "date >= %@ AND date < %@ AND mealType == %@", startOfToday, startOfTomorrow, NSNumber(integer: type))
		request.predicate = predicate
		let sortDes = NSSortDescriptor(key: "foodItem.name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
		request.sortDescriptors = [sortDes]
		let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
		controller.delegate = self
		return controller
	}
	
	// MAPPED INDEX PATH FOR SECTION
	//
	func mappedIndexPath(indexPath: NSIndexPath, forSection section: Int) -> NSIndexPath {
		return NSIndexPath(forRow: indexPath.row, inSection: section)
	}
	
}


// MARK: - MEAL SECTION HEADER VIEW DELEGATE
// ============================================================
extension TodayViewController: MealSectionHeaderViewDelegate {
	
	// BUTTON TAPPED
	//
	func headerViewButtonTappedForSection(section: Int) {
		performSegueWithIdentifier("ItemPickerSegue", sender: section)
	}
}

// MARK: - ITEM PICKER DELEGATE
// ============================================================
extension TodayViewController: ItemPickerViewControllerDelegate {
	
	// DID FINISH PICKING
	//
	func itemPickerViewController(picker: ItemPickerViewController, didFinishPickingItems items: [FoodItem], forMealType mealType: MealType) {

		// get all current portions for meal type
		let meal = mealControllers[mealType.rawValue]
		let currPortions = meal.fetchedObjects as! [Portion]
		// "uneat" each portion & delete
		for portion in currPortions {
			portion.foodItem.rule?.currentPeriod.count -= 1
			moc.deleteObject(portion)
		}
		
		// for each selected item
		for item in items {
			// create portion
			let entity = NSEntityDescription.entityForName("Portion", inManagedObjectContext: moc)!
			let portion = Portion(entity: entity, insertIntoManagedObjectContext: moc)
			portion.foodItem = item
			portion.meal = mealType
			portion.date = NSDate()
			// update food rule if any
			if let rule = portion.foodItem.rule {
				rule.currentPeriod.count += 1
			}
		}
		
		do {
			try moc.save()
		}
		catch let error as NSError {
			print("Could not save: \(error), \(error.userInfo)")
		}
		
		navigationController?.popViewControllerAnimated(true)
	}
}


// MARK: - FETCHED RESULTS CONTROLLER DELEGATE
// ============================================================
extension TodayViewController: NSFetchedResultsControllerDelegate {
	
	// WILL CHANGE CONTENT
	//
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		print("*** controllerWillChangeContent")
		tableView.beginUpdates()
	}
	
	// DID CHANGE OBJECT
	//
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		
		let controllerIndex = mealControllers.indexOf(controller)!
		
		switch type {
		case .Insert:
			print("*** fetchedResultsController insert")
			let newIndex = mappedIndexPath(newIndexPath!, forSection: controllerIndex)
			tableView.insertRowsAtIndexPaths([newIndex], withRowAnimation: .Fade)
		case .Delete:
			print("*** fetchedResultsController delete")
			let index = mappedIndexPath(indexPath!, forSection: controllerIndex)
			tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
		case .Update:
			print("*** fetchedResultsController update")
			// FIXME: optimize (update single cell)
			tableView.reloadData()
		case .Move:
			print("*** fetchedResultsController move")
			let oldIndex = mappedIndexPath(indexPath!, forSection: controllerIndex)
			let newIndex = mappedIndexPath(newIndexPath!, forSection: controllerIndex)
			tableView.deleteRowsAtIndexPaths([oldIndex], withRowAnimation: .Fade)
			tableView.insertRowsAtIndexPaths([newIndex], withRowAnimation: .Fade)
		}
	}
	
	// DID CHANGE CONTENT
	//
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		print("** controllerDidChangeContent")
		tableView.endUpdates()
	}
	
}

// MARK: - CALENDAR MANAGER DELEGATE
// ============================================================
extension TodayViewController: JTCalendarDelegate {
	
	// PREPARE DAY VIEW
	//
	func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
		
		let cal = calendarView
		let manager = calendarView.manager
		let dayView = dayView as! JTCalendarDayView
		
		// today
		if manager.dateHelper.date(NSDate(), isTheSameDayThan: dayView.date) {
			dayView.circleView.hidden = false
			dayView.circleView.backgroundColor = UINavigationBar.appearance().barTintColor
			dayView.dotView.backgroundColor = UIColor.whiteColor()
			dayView.textLabel.textColor = UIColor.whiteColor()
		}
		// selected date
		else if cal.dateSelected != nil && manager.dateHelper.date(cal.dateSelected!, isTheSameDayThan: dayView.date) {
			dayView.circleView.hidden = false
			dayView.circleView.backgroundColor = UIColor.redColor()
			dayView.dotView.backgroundColor = UIColor.whiteColor()
			dayView.textLabel.textColor = UIColor.whiteColor()
		}
		// other month
		else if !manager.dateHelper.date(cal.contentView.date, isTheSameMonthThan: dayView.date) {
			dayView.circleView.hidden = true
			dayView.dotView.backgroundColor = UIColor.redColor()
			dayView.textLabel.textColor = UIColor.lightGrayColor()
		}
		// another day of current month
		else {
			dayView.circleView.hidden = true
			dayView.dotView.backgroundColor = UIColor.redColor()
			dayView.textLabel.textColor = UIColor.blackColor()
		}
	}
	
	// DID TOUCH DAY VIEW
	//
	func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
		
		let dayView = dayView as! JTCalendarDayView
		calendarView.dateSelected = dayView.date
		
		// ani for cirlce view
		dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
		UIView.transitionWithView(dayView, duration: 0.3, options: [], animations: {
			
			dayView.circleView.transform = CGAffineTransformIdentity
			self.calendarView.manager.reload()
			
		}, completion: nil)
		
		// dont change page in week mode
		if calendarView.manager.settings.weekModeEnabled {
			return
		}
		
		// load previous or next page if touch in another month
		if !calendarView.manager.dateHelper.date(calendarView.contentView.date, isTheSameMonthThan: dayView.date) {
			if calendarView.contentView.date.compare(dayView.date) == .OrderedAscending {
				calendarView.contentView.loadNextPageWithAnimation()
			}
			else {
				calendarView.contentView.loadPreviousPageWithAnimation()
			}
		}
		
	}
	
	// CAN DISPLAY PAGE WITH DATE
	//
	func calendar(calendar: JTCalendarManager!, canDisplayPageWithDate date: NSDate!) -> Bool {
		if let minDate = calendarView.minDate, let maxDate = calendarView.maxDate {
			return calendarView.manager.dateHelper.date(date, isEqualOrAfter: minDate, andEqualOrBefore: maxDate)
		}
		else {
			return true
		}
	}
}







