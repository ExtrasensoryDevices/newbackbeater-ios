//
//  UIViewExtension.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-06-12.
//

import UIKit

extension UIView {
    func removeBorder() {
        layer.borderWidth = 0
    }
    
    func drawBorder() {
        drawBorder(color: ColorPalette.pink.color)
    }
    
    func drawBorder(width: CGFloat) {
        drawBorder(color: ColorPalette.pink.color, width: width)
    }
    
    func drawBorder(color: UIColor) {
        drawBorder(color: color, width: BORDER_WIDTH)
    }
    
    func drawBorder(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = self.bounds.size.height / 2
        self.clipsToBounds = true
    }
    
    
    func drawBorder(for layer:CALayer, color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = self.bounds.size.height / 2
    }
}
