//
//  Beer.swift
//  BeerButton
//
//  Created by Conrad Stoll on 11/1/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

import Foundation
import UIKit

struct Beer {
    var title = ""
    var image : UIImage?
    
    init(title : String, image : UIImage) {
        self.title = title
        self.image = image
    }
}

class BeerCell : UITableViewCell {
    @IBOutlet weak var beerLabel : UILabel?
    @IBOutlet weak var beerImage : UIImageView?
}