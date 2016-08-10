//
//  ComplicationController.swift
//  BeerButton WatchKit Extension
//
//  Created by Conrad Stoll on 11/1/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        var title : String?
        var date : Date?
        
        if let order = Order.currentOrder() {
            title = order.title
            date = order.date as Date
        }
        
        if let orderTitle = title, let orderDate = date {
            let entry = CLKComplicationTimelineEntry()
            let template = CLKComplicationTemplateModularLargeStandardBody()
            
            let headerTextProvider = CLKSimpleTextProvider(text: "Order Status")
            template.headerTextProvider = headerTextProvider
            
            let titleTextProvider = CLKSimpleTextProvider(text: orderTitle)
            template.body1TextProvider = titleTextProvider
            
            let timeTextProvider = CLKRelativeDateTextProvider(date: orderDate, style: .timer, units: .second)
            template.body2TextProvider = timeTextProvider
            
            entry.complicationTemplate = template
            entry.date = Date()
            
            handler(entry)
        } else {
            let entry = CLKComplicationTimelineEntry()
            let template = CLKComplicationTemplateModularLargeStandardBody()
            
            let headerTextProvider = CLKSimpleTextProvider(text: "Beer Button")
            template.headerTextProvider = headerTextProvider
            
            let titleTextProvider = CLKSimpleTextProvider(text: "Place Order")
            template.body1TextProvider = titleTextProvider
            
            entry.complicationTemplate = template
            entry.date = Date()
            
            handler(entry)
        }
    }
    
    func getNextRequestedUpdateDate(handler: (Date?) -> Void) {
        handler(nil);
    }
    
    
    // MARK: - Default Method Implementations

    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler(CLKComplicationTimeTravelDirections())
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        if let order = Order.currentOrder() {
            let date = order.date as Date
            
            let entry = CLKComplicationTimelineEntry()
            let template = CLKComplicationTemplateModularLargeStandardBody()
            
            let headerTextProvider = CLKSimpleTextProvider(text: "Beer Button")
            template.headerTextProvider = headerTextProvider
            
            let titleTextProvider = CLKSimpleTextProvider(text: "Place Order")
            template.body1TextProvider = titleTextProvider
            
            entry.complicationTemplate = template
            entry.date = date
            
            handler([entry])
        } else {
            handler(nil)   
        }
    }
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        handler(nil)
    }
    
}
