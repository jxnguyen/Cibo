//
//  Portion+CoreDataProperties.swift
//  Cibo
//
//  Created by John Nguyen on 03/09/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Portion {

    @NSManaged var date: NSDate
    @NSManaged var foodItem: FoodItem

}

