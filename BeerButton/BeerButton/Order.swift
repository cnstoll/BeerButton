//
//  Order.swift
//  BeerButton
//
//  Created by Conrad Stoll on 3/2/16.
//  Copyright © 2016 Conrad Stoll. All rights reserved.
//

import Foundation
import UIKit

struct Order {
    var title = ""
    var date : NSDate
    var beerDictionary : [String : AnyObject]
    
    init(beer : Beer, deliveryDate : NSDate) {
        self.title = beer.title
        self.beerDictionary = beer.toDictionary()
        self.date = deliveryDate
    }
    
    func send() -> OrderNotification {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(["title" : self.title, "date" : date, "beer" : self.beerDictionary], forKey: "order")
        
        let title = "Your " + self.title + " will be delivered in"
        let beer = Beer(dictionary: beerDictionary)
        
        let notification = OrderNotification(title: title, date: date, image: beer.image!)
        
        return notification
    }
    
    static func currentOrder() -> Order? {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let order = defaults.objectForKey("order") as? [String : AnyObject] {
            if let beerDictionary = order["beer"] as? [String : AnyObject] {
                let beer = Beer(dictionary: beerDictionary)
                let date = order["date"] as? NSDate
                
                if let orderDate = date {
                    let order = Order(beer: beer, deliveryDate: orderDate)
                    
                    return order
                }
            }
        }
        
        return nil
    }
    
    static func clearOrder() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: "order")
    }
    
    static func orderNotificationDictionary(notification : OrderNotification) -> [String : AnyObject] {
        let alert = ["body" : notification.title]
        let aps = ["alert" : alert, "category" : "BeerButtonOrderDelivery"]
        
        let dictionary = ["aps" : aps, "deliveryDate" : notification.date, "beerImage" : UIImagePNGRepresentation(notification.image)!]
        
        return dictionary
    }
    
    static func orderNotification(dictionary : [String : AnyObject]) -> OrderNotification {
        let title = dictionary["aps"]!["alert"]!!["body"]! as! String
        let date = dictionary["deliveryDate"]! as! NSDate
        let image = UIImage(data: dictionary["beerImage"]! as! NSData)!

        let notification = OrderNotification(title: title, date: date, image: image)
        
        return notification
    }
}

struct OrderNotification {
    let title : String
    let date : NSDate
    let image : UIImage
}

/*
 {
 "aps": {
    "alert": {
        "body": "Test message",
        "title": "Optional title"
    },
    "category": "BeerButtonOrderDelivery"
 },
 
 "WatchKit Simulator Actions": [
    {
        "title": "First Button",
        "identifier": "firstButtonAction"
    }
 ],
 
 "customKey": "Use this file to define a testing payload for your notifications. The aps dictionary specifies the category, alert text and title. The WatchKit Simulator Actions array can provide info for one or more action buttons in addition to the standard Dismiss button. Any other top level keys are custom payload. If you have multiple such JSON files in your project, you'll be able to select them when choosing to debug the notification interface of your Watch App."
 }
*/