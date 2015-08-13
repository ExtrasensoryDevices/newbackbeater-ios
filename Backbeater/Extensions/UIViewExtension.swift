//
//  UIViewExtension.swift
//  Backbeater
//
//  Created by Alina on 2015-06-12.
//

import UIKit

extension UIView {
    func removeBorder()
    {
        layer.borderWidth = 0
    }
    
    func drawBorder()
    {
        drawBorderWithColor(ColorPalette.Pink.color())
    }
    
    func drawBorderWithWidth(width: CGFloat)
    {
        drawBorderWithColor(ColorPalette.Pink.color(), width: width)
    }
    
    func drawBorderWithColor(color: UIColor)
    {
        drawBorderWithColor(color, width: BORDER_WIDTH)
    }
    
    func drawBorderWithColor(color: UIColor, width: CGFloat)
    {
        layer.borderColor = color.CGColor
        layer.borderWidth = width
        layer.cornerRadius = self.bounds.size.height / 2
        self.clipsToBounds = true
    }
    
    
    func drawBorderForLayer(aLayer:CALayer, color: UIColor, width: CGFloat)
    {
        aLayer.borderColor = color.CGColor
        aLayer.borderWidth = width
        aLayer.cornerRadius = self.bounds.size.height / 2
    }
}
