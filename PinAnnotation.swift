//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Lisue She on 6/27/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation
import MapKit

class PinAnnotation: MKPointAnnotation {
    var geoPin: GeoPin?
    var newPin: Bool = false
}
