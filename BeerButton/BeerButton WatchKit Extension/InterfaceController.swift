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

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var picker : WKInterfacePicker?
    @IBOutlet weak var button : WKInterfaceButton?
    @IBOutlet weak var label : WKInterfaceLabel?
    
    var beers : [Beer] = []
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
        
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    // WatchConnectivity Methods
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let array = applicationContext["beers"] as? [[String : AnyObject]] {
            beers.removeAll()
            
            for item in array {
                let beer = Beer(dictionary: item)
                beers.append(beer)
            }
        }
    }
}
