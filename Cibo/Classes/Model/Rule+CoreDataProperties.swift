//
//  Rule+CoreDataProperties.swift
//  Cibo
//
//  Created by John Nguyen on 30/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Rule {

	@NSManaged var times: Int16
    @NSManaged var days: Int16
    @NSManaged var isStrict: Bool
    @NSManaged var isActive: Bool
    @NSManaged var foodItem: FoodItem?

}
