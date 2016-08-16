//
//  NotificationController.swift
//  BeerButton
//
//  Created by Conrad Stoll on 4/11/16.
//  Copyright © 2016 Conrad Stoll. All rights reserved.
//

import Foundation
import UserNotifications
import WatchKit

class NotificationController : WKUserNotificationInterfaceController {
    
    @IBOutlet weak var label : WKInterfaceLabel?
    @IBOutlet weak var timer : WKInterfaceTimer?
    @IBOutlet weak var image : WKInterfaceImage?
    
    public func didReceive(_ notification: UNNotification, withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
        let request = notification.request
        let content = request.content
        let userInfo = content.userInfo
        
        let order = Order.orderNotification(userInfo)
        
        self.label?.setText(order.title)
        
        self.image?.setImage(order.image)
        
        self.timer?.setDate(order.date)
        self.timer?.start()

        completionHandler(.custom)
    }
}
