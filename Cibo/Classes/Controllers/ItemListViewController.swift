//
//  ItemListViewController.swift
//  Cibo
//
//  Created by John Nguyen on 17/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//

// TODO: SORT/GROUP BY TAGS

import UIKit
import CoreData

class ItemListViewController: UITableViewController {
	
	// MARK: - PROPERTIES & OUTLETS
	// ------------------------------------------------------------
	
	var moc: NSManagedObjectContext!
	
	// data source for table view
	lazy var fetchedResultsController: NSFetchedResultsController = {
		let request = NSFetchRequest(entityName: "FoodItem")
		let sortDes = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
		request.sortDescriptors = [sortDes]
		request.fetchBatchSize = 20
		let resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: "FoodItems")
		resultsController.delegate = self
		return resultsController
	}()
	
	// helpful vars for swipeable cell
	var cellCurrentlyOpen: SwipeableCell?
	var cellCurrentlyPanning: SwipeableCell?
	var detailSegueWaitingToBePerformedForIndexPath: NSIndexPath?
	var allowSwipe = true
	
	// MARK: - STANDARD
	// ============================================================
	
	deinit {
		fetchedResultsController.delegate = nil
	}
	
	// VIEW DID LOAD
	//
    override func viewDidLoad() {
        super.viewDidLoad()
		
		do {
			try fetchedResultsController.performFetch()
		}
		catch let error as NSError {
			print("Error fetching: \(error)")
		}
	}
	
	// VIEW WILL APPEAR
	//
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// FIXME: Optimise. reload only if needed
		tableView.reloadData()
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
		
		if segue.identifier == "ItemDetailSegue" {
			detailSegueWaitingToBePerformedForIndexPath = nil
			let vc = segue.destinationViewController as! ItemDetailViewController
			let indexPath = sender as! NSIndexPath
			let item = fetchedResultsController.objectAtIndexPath(indexPath) as? FoodItem
			vc.item = item
		}
		else if segue.identifier == "AddItemSegue" {
			let vc = segue.destinationViewController as! AddItemViewController
			vc.moc = moc
		}
		
	}

	// MARK: - HELPERS
	// ============================================================
	
	// CLOSE OTHER CELL NOT EQUAL TO CELL
	//
	func closeOtherCellNotEqualToCell(cell: SwipeableCell) {
		// if another cell already open
		if let openCell = cellCurrentlyOpen where openCell != cell {
			// close it
			openCell.resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: true)
		}
	}
}


// MARK: - TABLE VIEW DATA SOURCE
// ============================================================
extension ItemListViewController {
	
	// NUMBER OF ROWS
	//
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	// CELL FOR ROW
	//
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! SwipeableCell
		let item = fetchedResultsController.objectAtIndexPath(indexPath) as! FoodItem
		
		cell.delegate = self
		cell.mainTextLabel.text = item.name
		cell.rightDetailLabel.text = String(indexPath.row)
		
		if let days = item.daysSinceLastEaten() {
			var str = ""
			switch days {
			case 0:
				str = "today"
			case 1:
				str = "yesterday"
			default:
				str = "\(days) days ago"
			}
			cell.subTextLabel.text = str
		} else {
			if let rule = item.rule {
				cell.subTextLabel.text = rule.stringDescription
			} else {
				cell.subTextLabel.text = "Freely"
			}
		}
		
		return cell
	}
}

// MARK: - TABLE VIEW DELEGATE
// ============================================================
extension ItemListViewController {
	
	// HEIGHT FOR ROW
	//
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 66
	}
	
	// WILL SELECT ROW
	//
	override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		// if cell open
		if let cell = cellCurrentlyOpen {
			// close cell
			cell.resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: true)
			// if selected cell is not open cell, queue segue (performed when open cell closes)
			if let openIndexPath = tableView.indexPathForCell(cell) where openIndexPath != indexPath {
				detailSegueWaitingToBePerformedForIndexPath = indexPath
			}
		} else {
			// segue
			performSegueWithIdentifier("ItemDetailSegue", sender: indexPath)
		}
		return indexPath
	}
}

// MARK: - FETCHED RESULTS CONTROLLER DELEGATE
// ============================================================
extension ItemListViewController: NSFetchedResultsControllerDelegate {
	
	// WILL CHANGE CONTENT
	//
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		print("*** controllerWillChangeContent")
		tableView.beginUpdates()
	}
	
	// DID CHANGE OBJECT
	//
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		switch type {
		case .Insert:
			print("*** fetchedResultsController insert")
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
		case .Delete:
			print("*** fetchedResultsController delete")
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
		case .Update:
			print("*** fetchedResultsController update")
			// FIXME: optimize (update single cell)
			tableView.reloadData()
		case .Move:
			print("*** fetchedResultsController move")
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
		}
	}
	
	// DID CHANGE CONTENT
	//
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		print("*** controllerDidChangeContent")
		tableView.endUpdates()
	}
	
}

// MARK: - SWIPEABLE CELL DELEGATE
// ============================================================
extension ItemListViewController: SwipeableCellDelegate {
	
	// BUTTON 1 ACTION
	//
	func button1ActionForCell(cell: SwipeableCell) {
		print("DINNER!")
		cell.resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: true)
	}
	
	// BUTTON 2 ACTION
	//
	func button2ActionForCell(cell: SwipeableCell) {
		print("LUNCH!")
		cell.resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: true)
	}
	
	// BUTTON 3 ACTION
	//
	func button3ActionForCell(cell: SwipeableCell) {
		print("BREAKFAST!")
		cell.resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: true)
	}
	
	// CELL SHOULD OPEN
	//
	func cellShouldPan(cell: SwipeableCell) -> Bool {
		// can't open a multiple cells simultaneously
		if let openingCell = cellCurrentlyPanning where cell !== openingCell {
			return false
		}
		// detmerined by scroll view drag
		return allowSwipe
	}
	
	// CELL IS PANNING
	//
	func cellIsPanning(cell: SwipeableCell) {
		cellCurrentlyPanning = cell
		// dont allow vertial scroll
		tableView.scrollEnabled = false
	}
	
	// CELL WILL OPEN | Called when snap opens
	//
	func cellWillOpen(cell: SwipeableCell) {
		closeOtherCellNotEqualToCell(cell)
	}
	
	// CELL DID OPEN
	//
	func cellDidOpen(cell: SwipeableCell) {
		closeOtherCellNotEqualToCell(cell)
		// note open cell
		cellCurrentlyOpen = cell
		// unnote pannng cell
		cellCurrentlyPanning = nil
		tableView.scrollEnabled = true
	}
	
	// CELL DID CLOSE
	//
	func cellDidClose(cell: SwipeableCell) {
		// unote cell
		if let openCell = cellCurrentlyOpen where openCell === cell {
			cellCurrentlyOpen = nil
		}
		// unnote panning cell
		cellCurrentlyPanning = nil
		tableView.scrollEnabled = true
		
		if let indexPath = detailSegueWaitingToBePerformedForIndexPath {
			performSegueWithIdentifier("ItemDetailSegue", sender: indexPath)
		}
	}
	
}


// MARK: - SCROLL VIEW DELEGATE
// ============================================================

extension ItemListViewController {
	
	// WILL BEGIN DRAGGING
	//
	override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		// block horizonal cell swipe
		allowSwipe = false
		
		// if a cell is open
		if let openCell = cellCurrentlyOpen {
			// close it
			openCell.resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: true)
		}
		
	}
	
	// DID END DRAGGING
	//
	override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		// allow horizontal cell swipe
		allowSwipe = true
	}
}







