//
//  GeoPhoto+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Robert Alavi on 6/20/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation
import CoreData

@objc(GeoPhoto)
public class GeoPhoto: NSManagedObject {
    
    convenience init(GeoImage: NSData?, context: NSManagedObjectContext) {
         
        if let ent = NSEntityDescription.entity(forEntityName: "GeoPhoto", in: context) {
            self.init(entity: ent, insertInto: context)
            if let photo = GeoImage {
                self.photo = photo
            }
        } else {
            fatalError("Unable to find Entity: GeoPhoto!")
        }
    }
}
