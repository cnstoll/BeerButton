//
//  InterfaceController.swift
//  BeerButton WatchKit Extension
//
//  Created by Conrad Stoll on 11/1/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import ClockKit

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var group : WKInterfaceGroup?
    @IBOutlet weak var picker : WKInterfacePicker?
    @IBOutlet weak var button : WKInterfaceButton?
    @IBOutlet weak var timer : WKInterfaceTimer?
    
    var beers : [Beer] = []
    var currentBeer : Beer?
    var session : WCSession?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
        
        self.session = session
        
        restoreCachedBeers()
    }

    override func willActivate() {
        super.willActivate()
        
        resetOrder()
        
        self.updatePickerItems()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func restoreCachedBeers() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let array = defaults.objectForKey("beers") as? [[String : AnyObject]] {
            beers.removeAll()
            
            for item in array {
                let beer = Beer(dictionary: item)
                beers.append(beer)
            }
        }
    }
    
    func arrayOfBeerDictionaries() -> [[String : AnyObject]] {
        var array : [[String : AnyObject]] = []
        
        for item in beers {
            array.append(item.toDictionary())
        }
        
        return array
    }
    
    func updateCacheBeers() {
        let array = arrayOfBeerDictionaries()
        
        // Update Saved Cache
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(array, forKey: "beers")
    }
    
    func updatePickerItems() {
        var items : [WKPickerItem] = []
        
        for beer in beers {
            let item = WKPickerItem()
            item.title = beer.title
            
            if let image = beer.image {
                item.contentImage = WKImage(image: image)
            }
            
            items.append(item)
        }
        
        self.picker?.setItems(items)

        if (items.count > 0) {
            pickerDidChange(0)
        }
    }
    
    func resetOrder() {
        Order.clearOrder()
        
        self.group?.setHeight(100)
        self.button?.setTitle("Beer")
        self.group?.setWidth(100)
        self.group?.setCornerRadius(50)
        self.button?.setAlpha(1)
        self.timer?.setAlpha(0)
    }
    
    @IBAction func pickerDidChange(index : Int) {
        let beer = beers[index]
        currentBeer = beer
    
        self.group?.setBackgroundImage(beer.image)
        self.button?.setTitle(beer.title)
    }
    
    @IBAction func didOrderBeer(sender : WKInterfaceButton) {
        self.animateWithDuration(0.5, animations: {
            self.group?.setHeight(40)
            self.button?.setTitle("")
            self.group?.setWidth(40)
            self.group?.setCornerRadius(20)
            self.button?.setAlpha(0)
            self.timer?.setAlpha(1)
        })
        
        let date = NSDate(timeIntervalSinceNow: 22)
        
        self.timer?.setDate(date)
        self.timer?.start()
        
        if let beer = self.currentBeer {
            let notification = Order(beer: beer, deliveryDate: date).send()
            sendMessageNotification(notification)
        }
        
        let complicationServer = CLKComplicationServer.sharedInstance()
        
        for complication in complicationServer.activeComplications! {
            complicationServer.reloadTimelineForComplication(complication)
        }
    }
    
    // WatchConnectivity Methods
    
    func sendMessageNotification(notification : OrderNotification) {
        if let session = self.session {
            let message = Order.orderNotificationDictionary(notification)
            
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let array = applicationContext["beers"] as? [[String : AnyObject]] {
            beers.removeAll()
            
            for item in array {
                let beer = Beer(dictionary: item)
                beers.append(beer)
            }
            
            self.updatePickerItems()
            self.updateCacheBeers()
        }
    }
}
