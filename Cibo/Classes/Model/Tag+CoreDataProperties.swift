//
//  Tag+CoreDataProperties.swift
//  Cibo
//
//  Created by John Nguyen on 25/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tag {

	@NSManaged var name: String
    @NSManaged var imageName: String?
    @NSManaged var foodItems: NSSet?

}
