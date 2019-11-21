//
//  ImageViewController.swift
//  virtualTourist
//
//  Created by nic Wanavit on 11/17/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class ImageViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var reloadButton: UIButton!
    

    
    
    
    var dataController:DataController!
    var pin:Pin!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    // how many images on a page
    let imageTarget: Int = 20
    //observertoken
//    var saveObserverToken:Any?
    
    @IBAction func addImage(_ sender: Any) {
        print("add image button pressed")
        reloadAllImages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFetchResultsController()
        collectionView.delegate = self
        collectionView.dataSource = self
        nameLabel.text = pin.title
        setMapToCurrentLocation()
        displayPinOnMap()
        loadAllImages()
//        addSaveNotificationObserver()
        reloadButton.isEnabled = true
        reloadButton.setTitle("reloadImages", for: .normal)
        reloadButton.backgroundColor = .black
        reloadButton.setTitle("", for: .disabled)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        fetchedResultsController = nil
    }
    fileprivate func displayPinOnMap(){
        
        mapView.addAnnotation(pinToAnnotations(pin: pin))
    }
    
    fileprivate func setUpFetchResultsController(){
        let predictate = NSPredicate(format: "pin == %@", pin)
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = predictate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoIndex", ascending: false)]
        
//        NSFetchedResultsController<Photo>.deleteCache(withName: "photoIndex")
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photoIndex")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error fetching data \(error.localizedDescription)")
        }
        
    }
    //handle completed getFlickrImage randomly
    private func getFlickrImageCompletion(flikrImage:[FlickrImage]?)->Void{
        if let flikrImage = flikrImage{
            for fimage in flikrImage{
                let photoToAdd = Photo(context: dataController.viewContext)
                photoToAdd.photoURL = URL(string: fimage.imageURLString())
                photoToAdd.photoIndex = Int16(flikrImage.firstIndex{$0 === fimage}!)
                photoToAdd.pin = self.pin
                do {
                    try dataController.viewContext.save()
//                    print("note inserted called in addnote")
                    // image loading complete
                    print("image loading complete button activate")
                    DispatchQueue.main.async {
                        self.reloadButton.isEnabled = true
                    }
                } catch {
                    print("note saving error")
                }
            }
        } else {
            print("error loading flikrImage")
        }
    }
    
    private func setMapToCurrentLocation(){
            
        let currentLocation = CLLocation(latitude: self.pin.latitude, longitude: self.pin.longitude)
        self.mapView.setRegion(MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)), animated: true)
        mapView.mapType = .hybridFlyover
    }
    
    ////Flickr
    
    
    
    
    
    
}

// add or delete images
extension ImageViewController: UICollectionViewDelegate{
    

    
    
    func reloadAllImages(){
        deleteAllImages()
        loadAllImages()
    }
    func loadAllImages(){
        FlickrFunctions.getFlickrImagesRandomResult(pin: pin, imageTarget: imageTarget, completion: getFlickrImageCompletion(flikrImage:))
    }
    
    
    func deleteAllImages(){
        if let images = fetchedResultsController.fetchedObjects{
            for image in images{
                dataController.viewContext.delete(image)
            }
        }
    }
}
    
    
extension ImageViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of items are \(String(describing: fetchedResultsController.fetchedObjects?.count))")
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellForPhoto", for: indexPath) as! PhotoCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.activityIndicator.startAnimating()
        cell.initWithPhoto(photo)
        cell.viewContext = dataController.viewContext
        return cell
    }
    

}
    

extension ImageViewController:NSFetchedResultsControllerDelegate{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .delete:
            print("deleting picture")
        case .insert:
            print("pictures inserted")
//            DispatchQueue.main.async {
//                self.collectionView.insertItems(at: <#T##[IndexPath]#>)
//            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        default:
            break
        }
    }
    
}




//extension ImageViewController{
//    func preloadSavedPhoto() -> [Photo]? {
//        
//        do {
//            
//            var photoArray:[Photo] = []
//            try fetchedResultsController.performFetch()
//            let photoCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
//            
//            for index in 0..<photoCount {
//                
//                photoArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Photo)
//            }
//            
//            return photoArray.sorted(by: {$0.index < $1.index})
//            
//        } catch {
//            
//            return nil
//        }
//    }
//    func addSaveNotificationObserver(){
//
//        removeSaveNotificationObserver()
//        self.saveObserverToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: dataController.viewContext, queue: nil, using: handleSaveNotification(notification:))
//    }
//
//    func removeSaveNotificationObserver(){
//        if let token = saveObserverToken {
//            NotificationCenter.default.removeObserver(token)
//        }
//    }
//
//    fileprivate func updateImageToUI() {
//        collectionView.reloadData()
//
//    }
//
//    func handleSaveNotification(notification:Notification){
//        DispatchQueue.main.async {
//            self.updateImageToUI()
//        }
//    }
//}


