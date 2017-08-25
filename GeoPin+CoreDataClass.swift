//
//  GeoPin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Robert Alavi on 6/20/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation
import CoreData

@objc(GeoPin)
public class GeoPin: NSManagedObject {
 
    convenience init(locality: String, latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "GeoPin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.locality = locality
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
