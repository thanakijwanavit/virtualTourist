//
//  helperFunctions.swift
//  virtualTourist
//
//  Created by nic Wanavit on 11/20/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation
import MapKit
import CoreData

func pinToAnnotations(pin:Pin)->MKAnnotation{
    let annotation = MKPointAnnotation()
    let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    annotation.coordinate = location
    annotation.title = pin.title
    return annotation
}
func annotationToPin(annotation:MKPointAnnotation, dataController: DataController)->Pin{
    let pin = Pin(context: dataController.viewContext)
    pin.latitude = annotation.coordinate.latitude
    pin.longitude = annotation.coordinate.longitude
    pin.title = annotation.title
    return pin
}


func lookUpLocation(location:CLLocationCoordinate2D,completionHandler: @escaping (_ location:CLLocationCoordinate2D?,_ title:String?)
                -> Void ) {
    // Use the last reported location.
    let geocoder = CLGeocoder()
    let locationCL = CLLocation(latitude: location.latitude, longitude: location.longitude)
    // Look up the location and pass it to the completion handler
    geocoder.reverseGeocodeLocation(locationCL,
                completionHandler: { (placemarks, error) in
        if error == nil {
            let firstLocation = placemarks?[0]
            completionHandler(location,firstLocation?.name)
        }
        else {
         // An error occurred during geocoding.
            completionHandler(nil, nil)
            print("error transforming location to title")
        }
    })
}
