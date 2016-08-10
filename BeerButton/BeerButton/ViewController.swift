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
        
        let defaults = UserDefaults.standard
        
        if let array = defaults.object(forKey: "beers") as? [[String : AnyObject]] {
            for item in array {
                let beer = Beer(dictionary: item)
                beers.append(beer)
            }
        }
        
        updateWatchBeers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateWatchBeers()
    }

    @IBAction func addBeer(_ sender : AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func finishAddingBeer() {
        if let title = pickedTitle, let image = pickedImage {
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
        let defaults = UserDefaults.standard
        defaults.set(array, forKey: "beers")
    }
    
    // Session Methods
    
    func updateWatchBeers() {
        // Start Session
        let session = WCSession.default()
        session.delegate = self
        
        // Remember to activate session
        session.activate()
        
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
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    // Image Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismiss(animated: true, completion: {
            let alertController = UIAlertController(title: "Name your beer", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addTextField(configurationHandler: { (textField : UITextField) -> Void in
                self.textField = textField
            })
            
            let doneAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { (sender : UIAlertAction) -> Void in
                self.pickedTitle = self.textField?.text
                self.finishAddingBeer()
            })
            
            alertController.addAction(doneAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    // Table View Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeerCell", for: indexPath) as! BeerCell
        
        let beer = beers[(indexPath as NSIndexPath).row]
        
        cell.beerLabel?.text = beer.title
        
        if let image = beer.image {
            cell.beerImage?.image = image
        }
        
        return cell
    }
}

