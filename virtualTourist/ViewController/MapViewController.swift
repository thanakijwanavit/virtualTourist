//
//  ViewController.swift
//  virtualTourist
//
//  Created by nic Wanavit on 11/17/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController , CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var gestureRecognizerController: UILongPressGestureRecognizer!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var locationManager:CLLocationManager!
    var gestureRecognizerStart:Bool! = false
    var editMode: Bool = false
    var selectedPin: Pin? = nil
//    var pins:[Pin]!
    

    override func viewDidLoad() {
        locationManager = CLLocationManager()
        super.viewDidLoad()
        // setup map
        mapView.delegate = self
        configureMapView()
        setMapToCurrentLocation()
        // setup gesture recognizer
        gestureRecognizerController.delegate = self
        setUpFetchResultsController()
        addPinsToMap()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setRightBarButtonItem()
    }
    
    
    
    func setRightBarButtonItem() {
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    fileprivate func setUpFetchResultsController(){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error fetching data \(error.localizedDescription)")
        }
    }
    

    @IBAction func longPressed(_ sender: Any) {
//        print("i was pressed")
        if gestureRecognizerStart {
            let gestureRecognizer = sender as! UILongPressGestureRecognizer
            let gestureTouchLocation = gestureRecognizer.location(in: mapView)
            print("map was touched at \(gestureTouchLocation)")
            lookUpLocation(location: mapView.convert(gestureTouchLocation, toCoordinateFrom: mapView)) { (location, title) in
                if let location = location{
                    self.addAnnotationToMap(fromCoord: location, title: title)
                }
            }
            gestureRecognizerStart = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    setMapToCurrentLocation()
                }
            }
        }
    }
    
//// lookup location

/// update UI /////////////////
    
    // maps ui function
    
    func addAnnotationToMap(fromCoord: CLLocationCoordinate2D, title: String?) {
        
        //update data
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = fromCoord.latitude
        pin.longitude = fromCoord.longitude
        pin.title = title ?? ""
        do {
            try dataController.viewContext.save()
        } catch {
            print("error adding annotation to map \(error.localizedDescription)")
        }
        
        mapView.addAnnotation(pinToAnnotations(pin: pin))
        
        print("added annotation \(fromCoord) to memory")
    }

    private func setMapToCurrentLocation(){
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        view.backgroundColor = .gray
        if let location = locationManager.location {
                   print("the current location is \(location.coordinate)")
                   print("map is set to the current location")
            mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)), animated: true)
//                   mapView.setCenter(location.coordinate , animated: true)
//                   mapView.showsUserLocation = true
               }
               print("user location is \(mapView.isUserLocationVisible) visible")
    }
    private func configureMapView(){
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
        mapView.showsCompass = true
        mapView.showsTraffic = true
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.mapType = MKMapType.hybridFlyover
        print("map configured")
    }
    
    
    // add pins to map
    func addPinsToMap(){
        if let pins = fetchedResultsController.fetchedObjects {
            for pin in pins {
                mapView.addAnnotation(pinToAnnotations(pin: pin))
            }
        }
    }
    
    ///////update UI end /////////////////
    
}

//triggered after map view
extension MapViewController : MKMapViewDelegate{
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !self.editMode {
            // assign selected pin to the selected pin global variable
            self.selectedPin = annotationToPin(annotation: view.annotation as! MKPointAnnotation, dataController: dataController)
            // send pin to the next view
            performSegue(withIdentifier: "PinPhotos", sender: view.annotation?.coordinate)
//            fetchedResultsController = nil
            mapView.deselectAnnotation(view.annotation, animated: true)
        } else {
            dataController.viewContext.delete(annotationToPin(annotation: view.annotation as! MKPointAnnotation, dataController: dataController))
            do { try dataController.viewContext.save()
            } catch {
                print("saving error \(error.localizedDescription)")
            }
            print("pin removed from memory")
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PinPhotos"{
            let destination = segue.destination as! ImageViewController
            destination.dataController = self.dataController
            if let selectedPin = self.selectedPin{
                destination.pin = selectedPin
            } else {
                print("pin is invalid")
            }
        }
    }
    
}


//triggered if gesture control
extension MapViewController : UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizerStart = true
        return true
    }
}

//fetched result delegate

extension MapViewController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        mapView.update
       }
       
       func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//           tableView.endUpdates()
       }
       
       
       
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let seletedAnnotation = mapView.selectedAnnotations.first{
               switch type {
               case .delete:
                mapView.removeAnnotation(seletedAnnotation)
                print("delete is called \(String(describing: seletedAnnotation.title)) is deleted")
               case .insert:
                mapView.addAnnotation(seletedAnnotation)
                print("insert is called \(String(describing: seletedAnnotation.title)) is inserted")
               default:
                   break
                }
           }
       }
}



//edit mode
extension MapViewController{
    //add pins to map
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.editMode = editing
    }
    
}


