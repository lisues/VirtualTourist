//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Lisue She on 6/18/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
   
    var appDelegate: AppDelegate!
    var stack: CoreDataStack!
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        stack = appDelegate.stack
        
        mapView.delegate = self
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        
        fetchedResultsController = initFetchResultsController(predicate: nil)
        do {
            try self.fetchedResultsController?.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        let annotations: [PinAnnotation] = getCoreDataGeoPinRecord()
        mapView.addAnnotations(annotations)

        if appDelegate.initalLaunch && !appDelegate.pageAtPin && !(appDelegate.atLocality==nil) {
            DispatchQueue.main.async(){
                 self.performSegue(withIdentifier: "displayAlbum", sender: nil)
            }
        } else {
                appDelegate.pageAtPin = true
        }
        
        appDelegate.initalLaunch = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "displayAlbum", sender: view)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var newPin: Bool = false

        if segue.identifier! == "displayAlbum" {

            var geoPin:GeoPin?
            if let albumVC = segue.destination as? AlbumViewController {
                if let view=sender as? MKAnnotationView, let annotation=view.annotation as? PinAnnotation {
                    if let myObject = annotation.geoPin {
                        geoPin = myObject
                        newPin = annotation.newPin
                        annotation.newPin = false
                    }
                } else {
                    let pinArray: [GeoPin] = (self.fetchedResultsController?.fetchedObjects as? [GeoPin])!
                    for aPin in pinArray {
                        if aPin.locality == appDelegate.atLocality {
                            geoPin = aPin
                            break
                        }
                    }
                }
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GeoPhoto")
                
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photo", ascending: true)]
                
            let predicate = NSPredicate(format: "%K == %@", "photos", geoPin!)
            fetchRequest.predicate = predicate
            albumVC.geoPin = geoPin
            albumVC.newPin = newPin
                
            // Create FetchedResultsController
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
                
            albumVC.fetchedResultsController = fetchedResultsController
         }
        }

    }

    func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = PinAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)) { (placemarks, error) -> Void in
            
            if let pm = placemarks?[0] {
                if let locality=pm.locality {
                    annotation.title = locality
                } else if let fare=pm.thoroughfare, let subFare=pm.subThoroughfare {
                    annotation.title = fare + ", " + subFare
                } else if let administrativeArea=pm.administrativeArea {
                    annotation.title = administrativeArea
                } else if let country = pm.country {
                    annotation.title = country
                } else {
                    annotation.title = "\(touchMapCoordinate.latitude) \(touchMapCoordinate.longitude)"
                }
            } else {
                annotation.title = "\(touchMapCoordinate.latitude) \(touchMapCoordinate.longitude)"
            }
            
            let newPin = GeoPin(locality: annotation.title!, latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude, context: self.stack.context)
            annotation.geoPin = newPin
            annotation.newPin = true
            self.mapView.addAnnotation(annotation)
            self.stack?.save()
        }
    }

    func initFetchResultsController(predicate: NSPredicate? ) -> NSFetchedResultsController<NSFetchRequestResult>{
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GeoPin")
    
        // Add Sort Descriptors
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "locality", ascending: true),
                                        NSSortDescriptor(key: "latitude", ascending: false),
                                        NSSortDescriptor(key: "longitude", ascending: false)]
        
       // let predicate = NSPredicate(format: "%K == %@", "photos", geoPin!)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
    
        return fetchedResultsController
    }
   
    func getCoreDataGeoPinRecord() -> [PinAnnotation] {
     var annotations = [PinAnnotation]()

        if let fetchedObj = fetchedResultsController?.fetchedObjects {
            for pinObject in fetchedObj {
                let objIndexPath = fetchedResultsController?.indexPath(forObject: pinObject)
                let myObject = fetchedResultsController?.object(at: objIndexPath!) as! GeoPin
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(myObject.latitude), longitude: CLLocationDegrees(myObject.longitude))
                
                let annotation = PinAnnotation()
                annotation.coordinate = coordinate
                annotation.title = myObject.locality
                annotation.geoPin = myObject
                annotations.append(annotation)
            }
        }
        return annotations
    }

}


