//
//  UIViewExtension.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-06-12.
//

import UIKit

extension UIView {
    func removeBorder()
    {
        layer.borderWidth = 0
    }
    
    func drawBorder()
    {
        drawBorderWithColor(ColorPalette.pink.color())
    }
    
    func drawBorderWithWidth(_ width: CGFloat)
    {
        drawBorderWithColor(ColorPalette.pink.color(), width: width)
    }
    
    func drawBorderWithColor(_ color: UIColor)
    {
        drawBorderWithColor(color, width: BORDER_WIDTH)
    }
    
    func drawBorderWithColor(_ color: UIColor, width: CGFloat)
    {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = self.bounds.size.height / 2
        self.clipsToBounds = true
    }
    
    
    func drawBorderForLayer(_ aLayer:CALayer, color: UIColor, width: CGFloat)
    {
        aLayer.borderColor = color.cgColor
        aLayer.borderWidth = width
        aLayer.cornerRadius = self.bounds.size.height / 2
    }
}
