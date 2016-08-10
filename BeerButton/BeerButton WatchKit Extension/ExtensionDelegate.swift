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
        setNotificationPreferences()
    }

    func applicationDidBecomeActive() {
        deemphasizeOrder()
    }

    func applicationWillResignActive() {
        emphasizeOrder()
    }
    
    func applicationDidEnterBackground() {
        
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let snapshotTask = task as? WKSnapshotRefreshBackgroundTask {
                handleSnapshotTask(snapshotTask: snapshotTask)
            } else {
                handleRefreshTask(task: task)
            }
        }
    }
    
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
    
    func setNotificationPreferences() {
        let action = UNNotificationAction(identifier: "OrderDelivery", title: "Your Beer", options: .foreground)
        let category = UNNotificationCategory(identifier: "BeerButtonOrderDelivery", actions: [action], intentIdentifiers: [], options: UNNotificationCategoryOptions())
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.setNotificationCategories([category])
        
        center.requestAuthorization(options: [.alert]) { (granted, error) in }
    }
    
    /// MARK - UNUserNotificationCenterDelegate Methods
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
