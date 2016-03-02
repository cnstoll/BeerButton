//
//  Order.swift
//  BeerButton
//
//  Created by Conrad Stoll on 3/2/16.
//  Copyright © 2016 Conrad Stoll. All rights reserved.
//

import Foundation

struct Order {
    var title = ""
    var date : NSDate
    var beerDictionary : [String : AnyObject]
    
    init(beer : Beer, deliveryDate : NSDate) {
        self.title = beer.title
        self.beerDictionary = beer.toDictionary()
        self.date = deliveryDate
    }
    
    func send() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(["title" : self.title, "date" : date, "beer" : self.beerDictionary], forKey: "order")
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
}