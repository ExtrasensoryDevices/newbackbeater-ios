//
//  SegmentedButton.swift
//  Backbeater
//
//  Created by Alina on 2015-06-05.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import UIKit

class SegmentedButton: UIView {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var defaultImageName:String?
    var selectedImageName:String?
    
    var selected = false {
        didSet {
            //updateImage
        }
    }
    
    
}
