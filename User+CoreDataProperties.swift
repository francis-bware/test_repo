//
//  User+CoreDataProperties.swift
//  
//
//  Created by francis gallagher on 12/03/17.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var id: String?
    @NSManaged public var first_name: String?
    @NSManaged public var last_name: String?
    @NSManaged public var photo: String?
    @NSManaged public var sex: String?
    @NSManaged public var email: String?
    @NSManaged public var phone: String?

}
