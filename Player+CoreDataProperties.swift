//
//  Player+CoreDataProperties.swift
//  Dragging
//
//  Created by francis gallagher on 1/10/16.
//  Copyright © 2016 Testing. All rights reserved.
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player");
    }

    @NSManaged public var first_name: String?
    @NSManaged public var last_name: String?
    @NSManaged public var phone: String?
    @NSManaged public var email: String?
    @NSManaged public var row: NSNumber?
    @NSManaged public var position: NSNumber?
    @NSManaged public var id: String?
    @NSManaged public var teams: NSSet?
    @NSManaged public var photo: String?
    @NSManaged public var availability: String?
    @NSManaged public var finance: String?

}

extension Player {
    
    @objc(addTeamObject:)
    @NSManaged public func addToTeam(_ value: Team)

}
