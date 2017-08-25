###VirtualTourist###


========================================================================
DESCRIPTION:
The Virtual Tourist app downloads and stores images from Flickr. The app allows users to drop pins on a map, as if they were stops on a tour. Users will then be able to download pictures for the location and persist both the pictures, and the association of the pictures with the pin.


Supported Formats


=========================================================================
BUILDS REQUIREMENTS:


Xcode 8.2.1,  IOS SDK 8.2 or better, 


=========================================================================
RUNTIME REQUIREMENTS:


iPhone, iPad, or iPod Touch running iOS 8.2.1 or better Xcode 8.2.1,  IOS SDK 8.2.1 or better, 


=========================================================================
PACKAGING LIST:


NetworkClient/VirtualTouristNetwork
NetworkRequestAPIs class defines the APIs that are commonly used for http request methods,  GET, POST, DELETE, and PUT, from mobile apps. They are well defined to make requests to the RESTful web services who provides REST APIs.    


NetworkClient/VirtualTouristConstant.swift
Throughout the app, there are five different type of network requests to the Flickr RESTful web services. This file defines all the constants, parameters, and values needed to make the requests.   
 
NetworkClient/VirtualTouristFlickrResource.swift
VirtualTouristFlickrResource class provides all the functionalities needed for the network request to Flickr web services and parse receiving data from Flickr web services.  


model/CoreDataStack.swift
Defines CoreDataStack data structure to manage and configure persistence framework that allows data organized with related entity and attribute model to be serialized into SQLite stores.


model/GeoPin+CoreDataClass.swift
GeoPin class to define the data model entity.
model/GeoPin+CoreDataProperties.swift
Extension of GeoPin class. 


model/GeoPhoto+CoreDataClass.swift
GeoPhoto class to define the data model entity.


model/GeoPhoto+CoreDataProperties.swift
Extension of GeoPhoto class. 


VirtualTourCoreDataController.swift
VirtualTourCoreDataController class conforms NSFetchedResultsController.  It defines and provides the custom needs for fetched results delegates.  


MapViewController.swift
A UIViewController implements a root view controller to be the start point of the app .  It conforms with MKMapViewDelegate object. Using UILongPressGestureRecognizer object
to determine the location of the pin pressed by user.   It conforms with MKMapViewDelegate to populate the location of the results of pins which are stored in device to achieve persistence. 


AlbumViewController.swift
A UIViewController implements to popular the picture of the results from interact with Flickr RESTful APIs results in UICollectionView. 


AlbumCollectionViewCell.swift
AlbumCollectionViewCell class conforms UICollectionViewCell to customize the cell output for each custom review for the pictures.  


PinAnnotation.swift
PinAnnotation class conforms MKPointAnnotation.  It defines and provides the custom needs for this project.  
 
=========================================================================
CHANGES FROM PREVIOUS VERSION:


1.0 First Release


=========================================================================
Copyright © 2017 All rights reserved