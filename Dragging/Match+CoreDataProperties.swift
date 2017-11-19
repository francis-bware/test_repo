//
//  Match+CoreDataProperties.swift
//  
//
//  Created by francis gallagher on 28/05/17.
//
//

import Foundation
import CoreData


extension Match {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Match> {
        return NSFetchRequest<Match>(entityName: "Match");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: String?
    @NSManaged public var location: String?
    @NSManaged public var opposition_image: String?
    @NSManaged public var opposition_name: String?

}
