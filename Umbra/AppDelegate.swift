//
//  AppDelegate.swift
//  iQuiz
//
//  Created by Kelden Lin on 2/11/19.
//  Copyright © 2019 Kelden Lin. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import UserNotificationsUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        NotificationCenter.default.addObserver(self, selector:"calendarDayDidChange:", name:NSNotification.Name.NSCalendarDayChanged, object:nil)
        
        // Notifications
        // Enable notifications
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            //granted = yes, if app is authorized for all of the requested interaction types
            //granted = no, if one or more interaction type is disallowed
        }
        
        //Actions
        let remindHrAction = UNNotificationAction(identifier: "remindHr", title: "Remind 1 hour before", options: UNNotificationActionOptions(rawValue: 0))
        let completeAction = UNNotificationAction(identifier: "complete", title: "Complete Task", options: .foreground)
        
        //Category
        let taskCategory = UNNotificationCategory(identifier: "TASK", actions: [remindHrAction, completeAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        
        //Register the app’s notification types and the custom actions that they support.
        center.setNotificationCategories([taskCategory])
        center.delegate = self as! UNUserNotificationCenterDelegate

        return true
    }
    
    //Here you decide whether to silently handle the notification or still alert the user.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        //Write you app specific code here
        completionHandler([.alert, .sound]) //execute the provided completion handler block with the delivery option (if any) that you want the system to use. If you do not specify any options, the system silences the notification.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        switch response.notification.request.content.categoryIdentifier
        {
        case "GENERAL":
            break
            
        case "TASK":
            switch response.actionIdentifier
            {
            case "remindHr":
                print("remindLater")
                
            case "complete":
                print("accept")
                
            default:
                break
            }
            
        default:
            break
        }
        completionHandler()
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PersistenceService.saveContext()
    }
    
    var taskRepository : TaskRepository = CoreDataRepository.theInstance
}
