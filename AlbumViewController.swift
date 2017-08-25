//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Lisue She on 6/22/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class AlbumViewController: VirtualTourCoreDataController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    
    var appDelegate: AppDelegate!
    var stack: CoreDataStack!
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var geoPin: GeoPin?
    var newPin: Bool = false
    var downloadingPhoto = false
    var numberOfPhototSpace = 0
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var newCollection: UIButton!

    @IBOutlet weak var noImageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        stack = appDelegate.stack
        controllerView = albumCollectionView
        
        appDelegate.pageAtPin = false
        appDelegate.atLocality = geoPin?.locality

        mapView.delegate = self
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        
        switchImageViewLable(albumHidden: false, noImageLable: true)
        newCollection.isEnabled = true
     
        if let geoPin=geoPin {
            centerMapOnLocation(latitude: geoPin.latitude, longitude: geoPin.longitude)
        }
        
        //defineFlowLayout()
        
        do {
            try self.fetchedResultsController?.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    
        fetchedResultsController?.delegate = self
        if newPin {
            searchForFlickrPhotoDisplayOutput(latitude: geoPin!.latitude, longitude: geoPin!.longitude)
        } else if fetchedResultsController?.fetchedObjects?.count == 0 {
            switchImageViewLable(albumHidden: true, noImageLable: false)
        }
    }

       @IBAction func okOnThisTour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func searchForNewCollection(_ sender: Any) {
        
        let photosArray: [GeoPhoto] = (fetchedResultsController?.fetchedObjects as? [GeoPhoto])!
        for eachPhoto in photosArray {
            print(eachPhoto)
            stack.context.delete(eachPhoto)
        }
        self.stack?.save()
        searchForFlickrPhotoDisplayOutput(latitude: geoPin!.latitude, longitude: geoPin!.longitude)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if downloadingPhoto {
            return numberOfPhototSpace
        } else if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
        
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! AlbumCollectionViewCell
       
        if let fc = fetchedResultsController,
                fc.sections![indexPath.section].numberOfObjects > indexPath.row {
            let photo = fetchedResultsController?.object(at: indexPath) as! GeoPhoto
                cell.photoImage?.image = UIImage(data: photo.photo as! Data)
        } else {
            cell.photoImage?.image = UIImage(named: "default")
        }
        
        return cell
    }
     
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let myObject = fetchedResultsController?.object(at: indexPath) as! GeoPhoto
        stack.context.delete(myObject)
        self.stack?.save()
        
    }
    
    func centerMapOnLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {

        let location = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
        
    }
    
    func defineFlowLayout() {
        
        let space:CGFloat = 1.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        print("dimension: \(dimension)")
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        print("itemSize: \(flowLayout.itemSize)")
        
    }
    
    func switchImageViewLable(albumHidden: Bool, noImageLable: Bool) {
        
        self.albumCollectionView.isHidden = albumHidden
        self.noImageLabel.isHidden = noImageLable
        
        if noImageLable == false {
            DispatchQueue.main.async() {
                self.noImageLabel?.text = "No Image Available"
            }
        }
    }
    
    
    func searchForFlickrPhotoDisplayOutput(latitude: Double, longitude: Double) {
        
        newCollection.isEnabled = false
        
        getPhotosFromFlickr(latitude: latitude, longitude: longitude) { (numberOfPhoto) in
            
            if numberOfPhoto > 0 {
                self.switchImageViewLable(albumHidden: false, noImageLable: true)
                self.downloadingPhoto = true
                self.numberOfPhototSpace = numberOfPhoto
                DispatchQueue.main.async(){
                    self.albumCollectionView.reloadData()
                }
                
            } else {
                self.switchImageViewLable(albumHidden: true, noImageLable: false)
            }
        }
    }
    
    func getPhotosFromFlickr(latitude: Double, longitude: Double, completionHandlerForFlickrPhoto: @escaping (_ numberOfPhoto: Int) -> Void)  {
        
        var randomPage = 1
        var albumPhotos: [[String:AnyObject]]?
        
        VirtualTouristFlickrResource.sharedInstance.searchFlickrGeocoderPhotos(latitude: self.geoPin!.latitude, longitude:self.geoPin!.longitude, searchPage: randomPage) { (pages, photos) in
            
            if let newPhotos = photos {
                albumPhotos = newPhotos
                self.fetchedResultsController?.delegate = nil
                completionHandlerForFlickrPhoto(newPhotos.count)
            } else {
                completionHandlerForFlickrPhoto(0)
            }

            randomPage = Int(arc4random_uniform(UInt32(pages)))
            if pages > 1 && randomPage > 1 {
                    VirtualTouristFlickrResource.sharedInstance.searchFlickrGeocoderPhotos(latitude: self.geoPin!.latitude, longitude:self.geoPin!.longitude, searchPage: randomPage) { (pages, photos) in
                             self.manageDownloadImage(albumPhotos: photos)
                    }
            } else {
                    self.manageDownloadImage(albumPhotos: albumPhotos)
            }
        }
    
        return
    }
    
    func manageDownloadImage(albumPhotos: [[String:AnyObject]]?) {
        
        if let photos = albumPhotos {
            for photo in photos {
                if let imageURL = photo["url_m"] as? String {
                    let urlImage = URL(string: imageURL)
                    if let photoData = try? Data(contentsOf: urlImage!) {
                        let addPhoto = GeoPhoto(GeoImage: photoData as! NSData, context: self.stack.context)
                        addPhoto.photos = self.geoPin
                        self.stack.context.insert(addPhoto)
                        self.stack?.save()
                        
                        do {
                            try self.fetchedResultsController?.performFetch()
                        } catch {
                            let fetchError = error as NSError
                            print("\(fetchError), \(fetchError.userInfo)")
                        }
                        
                        DispatchQueue.main.async(){
                            self.albumCollectionView.reloadData()
                        }
                    }
                }
            }
            self.fetchedResultsController?.delegate = self
            self.downloadingPhoto = false
            DispatchQueue.main.async(){
                self.newCollection.isEnabled = true
            }
        }
    }
}
 
