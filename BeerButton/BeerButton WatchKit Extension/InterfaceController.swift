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
import UserNotifications

enum OrderStatus {
    case None
    case Ordered(Order, snapshot : Bool)
}

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var group : WKInterfaceGroup?
    @IBOutlet weak var picker : WKInterfacePicker?
    @IBOutlet weak var button : WKInterfaceButton?
    @IBOutlet weak var timer : WKInterfaceTimer?
    @IBOutlet weak var beerTitle : WKInterfaceLabel?
    
    var beers : [Beer] = []
    var currentBeer : Beer?
    var session : WCSession?
    
    var secondTimer : Timer?
    
    override func awake(withContext context: AnyObject?) {
        super.awake(withContext: context)
        
        let session = WCSession.default()
        session.delegate = self
        session.activate()
        
        self.session = session
        
        restoreCachedBeers()
        updatePickerItems()
        
        if let order = Order.currentOrder() {
            configureUI(status: .Ordered(order, snapshot: false))
            startTimer(forOrder: order)
        } else {
            configureUI(status: .None)
        }
    }
    
    // Lifecycle Methods

    override func willActivate() {
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        super.didDeactivate()

    }
    
    override func didAppear() {
        super.didAppear()
        
    }
    
    override func willDisappear() {
        super.willDisappear()
        
    }
    
    // Picker Methods
    
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
    
    @IBAction func pickerDidChange(_ index : Int) {
        let beer = beers[index]
        currentBeer = beer
    
        self.group?.setBackgroundImage(beer.image)
        self.button?.setTitle(beer.title)
    }
    
    // Order Methods
    
    @IBAction func resetOrder() {
        Order.clearOrder()
        configureUI(status: .None)
    }
    
    @IBAction func didOrderBeer(_ sender : WKInterfaceButton) {
        let date = Date(timeIntervalSinceNow: 30)
        
        if let beer = self.currentBeer {
            let order = Order(beer: beer, deliveryDate: date)
            
            let notification = order.send()
            let message = Order.orderNotificationDictionary(notification)
            notifyUser(message)
            
            self.animate(withDuration: 0.5, animations: {
                self.configureUI(status: .Ordered(order, snapshot: false))
            })
            
            startTimer(forOrder: order)
        }
        
        scheduleSnapshotRefresh(forDate: date)
        updateComplication()
    }
    
    // UI Methods
    
    func configureUI(status: OrderStatus) {
        if case .Ordered(_, let snapshot) = status {
            let size : CGFloat = snapshot ? 80 : 40
            
            self.group?.setHeight(size)
            self.button?.setTitle("")
            self.group?.setWidth(size)
            self.group?.setCornerRadius(size / 2)
            self.button?.setAlpha(0)
            self.timer?.setAlpha(1)
            self.beerTitle?.setAlpha(1)
        } else {
            self.group?.setHeight(100)
            self.button?.setTitle("Beer")
            self.group?.setWidth(100)
            self.group?.setCornerRadius(50)
            self.button?.setAlpha(1)
            self.timer?.setAlpha(0)
            self.timer?.stop()
            self.beerTitle?.setAlpha(0)
        }
    }
    
    func startTimer(forOrder order: Order) {
        self.timer?.setDate(order.date)
        self.timer?.start()
        
        self.secondTimer?.invalidate()
        self.secondTimer = nil
        
        self.secondTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (_) in
            let currentTime = Date().timeIntervalSinceNow
            let arrivalTime = order.date.timeIntervalSinceNow
            let remainingTime = arrivalTime - currentTime
            
            if remainingTime < 0 {
                self.resetOrder()
                self.secondTimer?.invalidate()
                self.secondTimer = nil
            }
            
            self.beerTitle?.setText(String(remainingTime))
        })
    }
    
    func scheduleSnapshotRefresh(forDate date: Date) {
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: date, userInfo: nil, scheduledCompletion: { error in
            
        })
    }
    
    func updateComplication() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        
        for complication in complicationServer.activeComplications! {
            complicationServer.reloadTimeline(for: complication)
        }
    }
    
    // Notification Methods
    
    func notifyUser(_ message : [String : AnyObject]) {
        let orderInfo = Order.orderNotification(message)
        
        let content = UNMutableNotificationContent()
        content.body = orderInfo.title
        content.title = "Beer Delivery"
        content.userInfo = message
        content.categoryIdentifier = "BeerButtonOrderDelivery"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: orderInfo.date.timeIntervalSinceNow - 10, repeats: false)
        
        let _ = UNNotificationRequest(identifier: "Delivery", content: content, trigger: trigger)
        let _ = UNUserNotificationCenter.current()

        // Disabled due to Xcode 8 Beta 5 Simulator Bug
        //center.add(request, withCompletionHandler: nil)
    }
    
    // WatchConnectivity Methods
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
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
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // Beer Model Methods
    
    func restoreCachedBeers() {
        let defaults = UserDefaults.standard
        
        if let array = defaults.object(forKey: "beers") as? [[String : AnyObject]] {
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
        let defaults = UserDefaults.standard
        defaults.set(array, forKey: "beers")
    }
}
