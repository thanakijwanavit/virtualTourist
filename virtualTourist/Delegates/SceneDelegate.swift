//
//  SceneDelegate.swift
//  virtualTourist
//
//  Created by nic Wanavit on 11/17/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "CoreDataModel")


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let mapViewController = navigationController.topViewController as! MapViewController
        mapViewController.dataController = dataController
        print("app finished loading")
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
}

