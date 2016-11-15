//
//  ExtensionDelegate.swift
//  BeerButton WatchKit Extension
//
//  Created by Conrad Stoll on 11/1/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

import ClockKit
import UserNotifications
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {

    func applicationDidFinishLaunching() {
    }

    func applicationDidBecomeActive() {
        setNotificationPreferences()
        deemphasizeOrder()
    }

    func applicationWillResignActive() {
        emphasizeOrder()
    }
    
    func applicationDidEnterBackground() {
        
    }
    
    /// MARK - Background Refresh Methods
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let snapshotTask = task as? WKSnapshotRefreshBackgroundTask {
                handleSnapshotTask(snapshotTask: snapshotTask)
            } else {
                handleRefreshTask(task: task)
            }
        }
    }
    
    /// MARK - Notification Methods
    
    func setNotificationPreferences() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                let category = UNNotificationCategory(identifier: "BeerButtonOrderDelivery", actions: [], intentIdentifiers: [], options: [])
                center.setNotificationCategories(Set([category]))
            } else {
                print("No Permissions" + error.debugDescription)
            }
        }
    }
    
    /// MARK - UNUserNotificationCenterDelegate Methods
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        completionHandler([.alert, .sound])
    }
}

extension ExtensionDelegate {
    /// MARK - Background Update Methods
    
    func handleSnapshotTask(snapshotTask : WKSnapshotRefreshBackgroundTask) {
        if let order = Order.currentOrder() {
            updateSnapshot(status: .Ordered(order, snapshot: true))
            snapshotTask.setTaskCompleted(restoredDefaultState: false, estimatedSnapshotExpiration: order.date, userInfo: nil)
        } else {
            updateSnapshot(status: .None)
            snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
        }
    }
    
    func handleRefreshTask(task : WKRefreshBackgroundTask) {
        // Handle our refresh by reloading our complication timeline
        let complicationServer = CLKComplicationServer.sharedInstance()
        
        for complication in complicationServer.activeComplications! {
            complicationServer.reloadTimeline(for: complication)
        }
        
        task.setTaskCompleted()
    }
    
    /// MARK - Internal Methods
    
    func emphasizeOrder() {
        if let order = Order.currentOrder() {
            updateSnapshot(status: .Ordered(order, snapshot: true))
        } else {
            updateSnapshot(status: .None)
        }
    }
    
    func deemphasizeOrder() {
        if let interfaceController = WKExtension.shared().rootInterfaceController as? InterfaceController {
            interfaceController.animate(withDuration: 0.5, animations: {
                if let order = Order.currentOrder() {
                    self.updateSnapshot(status: .Ordered(order, snapshot: false))
                } else {
                    self.updateSnapshot(status: .None)
                }
            })
        }
    }
    
    func updateSnapshot(status: OrderStatus) {
        if let interfaceController = WKExtension.shared().rootInterfaceController as? InterfaceController {
            interfaceController.configureUI(status: status)
        }
    }
    
    func scheduleBackgroundRefresh() {
        // Initiate a background refresh for 5 minutes from now.
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: 60 * 5), userInfo: nil) { (error) in
            
        }
    }
}
