//
//  GeoPhoto+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Robert Alavi on 6/20/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation
import CoreData


extension GeoPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GeoPhoto> {
        return NSFetchRequest<GeoPhoto>(entityName: "GeoPhoto");
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var photos: GeoPin?

}
