//
//  GeoPin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Robert Alavi on 6/20/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation
import CoreData


extension GeoPin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GeoPin> {
        return NSFetchRequest<GeoPin>(entityName: "GeoPin");
    }

    @NSManaged public var locality: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var album: NSSet?

}

// MARK: Generated accessors for album
extension GeoPin {

    @objc(addAlbumObject:)
    @NSManaged public func addToAlbum(_ value: GeoPhoto)

    @objc(removeAlbumObject:)
    @NSManaged public func removeFromAlbum(_ value: GeoPhoto)

    @objc(addAlbum:)
    @NSManaged public func addToAlbum(_ values: NSSet)

    @objc(removeAlbum:)
    @NSManaged public func removeFromAlbum(_ values: NSSet)

}
