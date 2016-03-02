//
//  GlanceController.swift
//  BeerButton WatchKit Extension
//
//  Created by Conrad Stoll on 11/1/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    @IBOutlet weak var image : WKInterfaceImage?
    @IBOutlet weak var timer : WKInterfaceTimer?
    @IBOutlet weak var label : WKInterfaceLabel?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        
        var title : String?
        var date : NSDate?
        var beer : Beer?
        
        if let order = Order.currentOrder() {
            title = order.title
            date = order.date
            beer = Beer(dictionary: order.beerDictionary)
            
            if let orderDate = date {
                self.timer?.setDate(orderDate)
            }
            
            if let orderTitle = title {
                self.label?.setText(orderTitle)
            }
            
            self.timer?.start()
            self.image?.setImage(beer?.image)
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
