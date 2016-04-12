//
//  ViewController.swift
//  BeerButton
//
//  Created by Conrad Stoll on 11/1/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, WCSessionDelegate {

    var textField : UITextField?
    var pickedImage : UIImage?
    var pickedTitle : String?
    
    var beers : [Beer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let array = defaults.objectForKey("beers") as? [[String : AnyObject]] {
            for item in array {
                let beer = Beer(dictionary: item)
                beers.append(beer)
            }
        }
        
        updateWatchBeers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateWatchBeers()
    }

    @IBAction func addBeer(sender : AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func finishAddingBeer() {
        if let title = pickedTitle, image = pickedImage {
            let thumbnail = image.squareImageTo(CGSize(width: 100, height: 100))
            
            let beer = Beer(title: title, image: thumbnail)
            beers.append(beer)
        }
        
        updateWatchBeers()
        updateCacheBeers()
        tableView.reloadData()
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
    
    // Session Methods
    
    func updateWatchBeers() {
        // Start Session
        let session = WCSession.defaultSession()
        session.delegate = self
        
        // Remember to activate session
        session.activateSession()
        
        // Update Context
        var context = session.applicationContext
        
        context["beers"] = arrayOfBeerDictionaries()
        
        // Send Message
        do {
            try session.updateApplicationContext(context)
        } catch let error {
            print(error)
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        self.notifyUser(message)
    }
    
    // Image Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: {
            let alertController = UIAlertController(title: "Name your beer", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addTextFieldWithConfigurationHandler({ (textField : UITextField) -> Void in
                self.textField = textField
            })
            
            let doneAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: { (sender : UIAlertAction) -> Void in
                self.pickedTitle = self.textField?.text
                self.finishAddingBeer()
            })
            
            alertController.addAction(doneAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    // Table View Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BeerCell", forIndexPath: indexPath) as! BeerCell
        
        let beer = beers[indexPath.row]
        
        cell.beerLabel?.text = beer.title
        
        if let image = beer.image {
            cell.beerImage?.image = image
        }
        
        return cell
    }
    
    // Notification Methods
    
    func notifyUser(message : [String : AnyObject]) {
        let action = UIMutableUserNotificationAction()
        action.identifier = "OrderDelivery"
        action.title = "Your Beer"
        action.activationMode = .Foreground
        action.authenticationRequired = false
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = "BeerButtonOrderDelivery"
        category.setActions([action], forContext: .Default)
        
        let settings = UIUserNotificationSettings(forTypes: .Alert, categories:Set(arrayLiteral: category))
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        let orderInfo = Order.orderNotification(message)

        let localNotif = UILocalNotification()
        localNotif.fireDate = NSDate(timeIntervalSinceNow: orderInfo.date.timeIntervalSinceNow - 10)
        localNotif.timeZone = NSTimeZone.defaultTimeZone()
        
        localNotif.alertTitle = "Beer Delivery"
        localNotif.alertBody = orderInfo.title
        localNotif.category = "BeerButtonOrderDelivery"
        localNotif.userInfo = message

        UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
    }
}

