//
//  FoodItem+CoreDataProperties.swift
//  Cibo
//
//  Created by John Nguyen on 26/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FoodItem {

    @NSManaged var name: String
    @NSManaged var rule: Rule?
    @NSManaged var tags: NSSet?
    @NSManaged var portions: NSSet?

}
