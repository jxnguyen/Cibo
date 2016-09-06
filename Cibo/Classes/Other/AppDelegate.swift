//
//  AppDelegate.swift
//  Cibo
//
//  Created by John Nguyen on 06/09/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		customizeAppearance()
		
		// dummy data
		let request = NSFetchRequest(entityName: "FoodItem")
		
		do {
			let results = try managedObjectContext.executeFetchRequest(request) as! [FoodItem]
			
			if results.isEmpty {
				let foodEntity = NSEntityDescription.entityForName("FoodItem", inManagedObjectContext: managedObjectContext)!
				let ruleEntity = NSEntityDescription.entityForName("Rule", inManagedObjectContext: managedObjectContext)!
				
				let item1 = FoodItem(entity: foodEntity, insertIntoManagedObjectContext: managedObjectContext)
				item1.name = "Carrot"
				let rule1 = Rule(times: 1, days: 3, entity: ruleEntity, context: managedObjectContext)
				item1.rule = rule1
				
				let item2 = FoodItem(entity: foodEntity, insertIntoManagedObjectContext: managedObjectContext)
				item2.name = "Turkey"
				let rule2 = Rule(times: 3, days: 5, entity: ruleEntity, context: managedObjectContext)
				item2.rule = rule2
				
				let item3 = FoodItem(entity: foodEntity, insertIntoManagedObjectContext: managedObjectContext)
				item3.name = "Pasta"
				let rule3 = Rule(times: 1, days: 2, entity: ruleEntity, context: managedObjectContext)
				item3.rule = rule3
				
				let item4 = FoodItem(entity: foodEntity, insertIntoManagedObjectContext: managedObjectContext)
				item4.name = "Beef"
				
				let item5 = FoodItem(entity: foodEntity, insertIntoManagedObjectContext: managedObjectContext)
				item5.name = "Bacon"
				
				do {
					try managedObjectContext.save()
				}
				catch let error as NSError {
					print("Error saving: \(error)")
				}
			}
		}
		catch let error as NSError {
			print("Error fetching results: \(error)")
		}
		
		// propagate moc
		let tabVC = window!.rootViewController as! UITabBarController
		let nav1VC = tabVC.viewControllers![0] as! UINavigationController
		let nav2VC = tabVC.viewControllers![1] as! UINavigationController
		let todayVC = nav1VC.topViewController! as! TodayViewController
		let listVC = nav2VC.topViewController! as! ItemListViewController
		todayVC.moc = managedObjectContext
		listVC.moc = managedObjectContext
		
		return true
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
		self.saveContext()
	}
	
	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.
		self.saveContext()
	}
	
	// MARK: - Core Data stack
	
	lazy var applicationDocumentsDirectory: NSURL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory named "edu.john.Cibo" in the application's documents Application Support directory.
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count-1]
	}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = NSBundle.mainBundle().URLForResource("Cibo", withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		// The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
		var failureReason = "There was an error creating or loading the application's saved data."
		do {
			try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
		} catch {
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}
		
		return coordinator
	}()
	
	lazy var managedObjectContext: NSManagedObjectContext = {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
	
	// MARK: - Core Data Saving support
	
	func saveContext () {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
		}
	}
	
	// MARK: - HELPERS
	// ============================================================
	
	// CUSTOMIZE APPEARANCE
	//
	func customizeAppearance() {
		// red tint
		let tintColor = UIColor(red: 255/255.0,
		                        green: 83/255.0,
		                        blue: 73/255.0,
		                        alpha: 1.0)
		// nav bar
		UINavigationBar.appearance().barTintColor = tintColor
		UINavigationBar.appearance().tintColor = UIColor.whiteColor()
		UINavigationBar.appearance().titleTextAttributes = [
			NSForegroundColorAttributeName: UIColor.whiteColor()
		]
		
	}
	
	
	
}

