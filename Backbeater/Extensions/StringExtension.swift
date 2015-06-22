//
//  StringExtension.swift
//  Backbeater
//
//  Created by Alina on 2015-06-19.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}