//
//  PhotoCell.swift
//  virtualTourist
//
//  Created by nic Wanavit on 11/20/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation
import UIKit
import CoreData



class PhotoCell:UICollectionViewCell{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var viewContext:NSManagedObjectContext!
    
    
    
    func initWithPhoto(_ photo: Photo) {
           
           if photo.photoData != nil {
               print("photo data exist")
               DispatchQueue.main.async {
                   
                   self.imageView.image = UIImage(data: photo.photoData! as Data)
                   self.activityIndicator.stopAnimating()
               }
               
           } else {
               print("photo data doesnt exist")
               downloadImage(photo)
           }
       }
    
    func downloadImage(_ photo: Photo) {
        
        URLSession.shared.dataTask(with: photo.photoURL!) { (data, response, error) in
            if error == nil {
                print("image downloaded")
                DispatchQueue.main.async {
                    
                    self.imageView.image = UIImage(data: data! as Data)
                    self.activityIndicator.stopAnimating()
                    self.saveImageDataToCoreData(photo: photo, imageData: data! as Data)
                    }
                } else {
                print("error loading photo \(error.debugDescription)")
                }
            }
            .resume()
    }
    
    func saveImageDataToCoreData(photo: Photo, imageData: Data) {
        do {
            photo.photoData = imageData
//            let delegate = SceneDelegate()
//            let context = delegate.dataController.viewContext
            try viewContext.save()
            
        } catch {
            print("Saving Photo imageData Failed \(error.localizedDescription)")
        }
    }
    
    
}
