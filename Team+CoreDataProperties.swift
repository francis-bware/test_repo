//
//  Team+CoreDataProperties.swift
//  
//
//  Created by francis gallagher on 13/12/16.
//
//

import Foundation
import CoreData
import 

extension Team {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team");
    }

    @NSManaged public var name: String?
    @NSManaged public var id: Int64
    @NSManaged public var sport: String?
    @NSManaged public var owner: Bool
    @NSManaged public var players: NSSet?

}

// MARK: Generated accessors for players
extension Team {

    @objc(addPlayersObject:)
    @NSManaged public func addToPlayers(_ value: Player)

    @objc(removePlayersObject:)
    @NSManaged public func removeFromPlayers(_ value: Player)

    @objc(addPlayers:)
    @NSManaged public func addToPlayers(_ values: NSSet)

    @objc(removePlayers:)
    @NSManaged public func removeFromPlayers(_ values: NSSet)

}
