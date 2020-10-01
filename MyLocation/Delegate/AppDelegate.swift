//  889
//  AppDelegate.swift
//  MyLocation
//
//  Created by DenisSuspitsyn on 21.09.2020.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Passing the CoreDataContext
        let tabController = window!.rootViewController as! UITabBarController
        
        // ManagedObjectContext
        if let tabViewController = tabController.viewControllers {
            //First tab
            var navController = tabViewController[0] as! UINavigationController
            let controller1 = navController.viewControllers.first as! CurrentLocationViewController
            controller1.managedObjectContext = managedObjectContext
            
            // Second tab
            navController = tabViewController[1] as! UINavigationController
            let controller2 = navController.viewControllers.first as! LocationsViewController
            controller2.managedObjectContext = managedObjectContext
        }
        
        listenForFatalCoreDataNotifications()
        
        return true
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext  = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Helper methods
    func listenForFatalCoreDataNotifications() {
        NotificationCenter.default.addObserver(forName: CoreDataSaveFailedNotification,
                                               object: nil, queue: .main) { notification in
            let message = """
            There was a fatal error in the app and it cannot continue.
            Press OK to terminate the app. Sorry for the inconvenience.
            """
            
            let alert = UIAlertController(title: "Internal Error",
                                          message: message,
                                          preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK",
                                       style: .default) { _ in
                let exception = NSException(name: .internalInconsistencyException,
                                            reason: "Fatal Core Data Error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
                
            let tabController = self.window!.rootViewController!
            tabController.present(alert, animated: true, completion: nil)
        }
    }
    
}

