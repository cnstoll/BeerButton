//
//  ViewController.swift
//  BeerButton
//
//  Created by Conrad Stoll on 11/1/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var textField : UITextField?
    var pickedImage : UIImage?
    var pickedTitle : String?
    
    var beers : [Beer] = []

    @IBAction func addBeer(sender : AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func finishAddingBeer() {
        if let title = pickedTitle, image = pickedImage {
            let beer = Beer(title: title, image: image)
            beers.append(beer)
        }
        
        tableView.reloadData()
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
}

