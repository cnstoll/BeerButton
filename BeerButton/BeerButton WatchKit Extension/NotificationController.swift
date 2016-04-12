//
//  NotificationController.swift
//  BeerButton
//
//  Created by Conrad Stoll on 4/11/16.
//  Copyright © 2016 Conrad Stoll. All rights reserved.
//

import Foundation
import WatchKit

class NotificationController : WKUserNotificationInterfaceController {
    
    @IBOutlet weak var label : WKInterfaceLabel?
    @IBOutlet weak var timer : WKInterfaceTimer?
    @IBOutlet weak var image : WKInterfaceImage?
    
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
        print(localNotification.userInfo)
        
        let payload = localNotification.userInfo as! [String : AnyObject]
        let notification = Order.orderNotification(payload)
        
        self.label?.setText(notification.title)
        
        self.image?.setImage(notification.image)

        self.timer?.setDate(notification.date)
        self.timer?.start()
        
        completionHandler(.Custom)
    }
}