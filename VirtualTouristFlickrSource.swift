//
//  VirtualTouristFlickrResource.swift
//  VirtualTourist
//
//  Created by Lisue She on 6/19/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation

class VirtualTouristFlickrResource {

   
    func searchFlickrGeocoderPhotos(latitude: Double, longitude: Double, searchPage: Int, completionHandlerForFlickrPhotos: @escaping (_ pages: Int, _ photos: [[String:AnyObject]]? ) -> Void) {
    
        let parameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod as AnyObject,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey as AnyObject,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL as AnyObject,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat as AnyObject,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback as AnyObject,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch as AnyObject,
            Constants.FlickrParameterKeys.Page: searchPage as AnyObject,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPage as AnyObject,
            Constants.FlickrParameterKeys.Latitude: latitude as AnyObject,
            Constants.FlickrParameterKeys.Longitude: longitude as AnyObject ]
    
        VirtualTouristNetwork.sharedInstance.taskRequest(nil, Constants.Flickr.APIPath, addHeaderField: nil, setHeaderField: nil, parameters: parameters, jsonBody: nil) { (data, error) in
            
            guard let data=data else {
                print("Client task request failed")
                completionHandlerForFlickrPhotos(0, nil)
                return
            }
            
            print("get data, let parse it")

            let parsedData: [String:AnyObject]!
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                for (key,value) in parsedData {
                    print("\(key): \(value)")
                }
                
                guard let photosInfo=parsedData["photos"] as? [String:AnyObject] else {
                    print("error: 1")
                    completionHandlerForFlickrPhotos(0, nil)
                    return
                }
                print("*page: \(photosInfo["page"])")
                print("*pages: \(photosInfo["pages"])")
                print("*perpage: \(photosInfo["perpage"])")
                print("*total: \(photosInfo["total"])")
                    
                if let photos=photosInfo["photo"] as? [[String:AnyObject]], let pages=photosInfo["pages"] as? Int {
                    completionHandlerForFlickrPhotos(pages, photos)
                } else {
                    completionHandlerForFlickrPhotos(0, nil)
                }
                return
            } catch {
                completionHandlerForFlickrPhotos(0, nil)
                return
            }
        }
    }
    
    static let sharedInstance = VirtualTouristFlickrResource()
}


