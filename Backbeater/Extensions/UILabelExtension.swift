//
//  UILabelExtension.swift
//

import UIKit

extension UILabel {
    func fontSizeToFit(minFontSize: CGFloat) {
        if self.text == nil {
            return
        }
        
        let maxLines = self.numberOfLines == 0 ? Int.max : self.numberOfLines
        
        var bestFont = self.font
        let words = split(self.text!) {$0 == " " || $0 == "\n"}
        for word in words {
            let minFont = fontSizeToFitCalculateMinFontForSubText(" \(word) ", minFontSize: minFontSize, maxLines: 1)
            if minFont.pointSize < bestFont.pointSize {
                bestFont = minFont
            }
        }
        
        let minTextFont = fontSizeToFitCalculateMinFontForSubText(text!, minFontSize: minFontSize, maxLines: maxLines)
        if minTextFont.pointSize < bestFont.pointSize {
            bestFont = minTextFont
        }
        
        self.font = bestFont
    }
    
    func fontSizeToFit() {
        fontSizeToFit(0.0)
    }
    
    private func fontSizeToFitCalculateMinFontForSubText(text: String, minFontSize: CGFloat, maxLines: Int) -> UIFont {
        let maxHeight = self.bounds.height

        var testFont = self.font
        var size = fontSizeTofitCalculateSizeForFont(testFont, text: text)
        
        while maxHeight < size.height || CGFloat(maxLines) < floor(size.height / testFont.pointSize) {
            testFont = testFont.fontWithSize(testFont.pointSize - 0.5)
            size = fontSizeTofitCalculateSizeForFont(testFont, text: text)
            if testFont.pointSize < minFontSize {
                break;
            }
        }
        
        return testFont
    }
    
    private func fontSizeTofitCalculateSizeForFont(font: UIFont, text: String) -> CGSize {
        
        let boundingWidth = self.bounds.width
        let boundingHeight = CGFloat.max
        let options = unsafeBitCast(
            NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.UsesFontLeading.rawValue,
            NSStringDrawingOptions.self
        )
        
        var attributes = NSMutableDictionary(dictionary: [NSFontAttributeName: font])
        if let concreteAttributedText = self.attributedText {
            if let kern = concreteAttributedText.attribute(NSKernAttributeName, atIndex: 0, effectiveRange: nil) as? CGFloat {
                attributes.setObject(kern, forKey: NSKernAttributeName)
            }
            
            if let style = concreteAttributedText.attribute(NSParagraphStyleAttributeName, atIndex: 0, effectiveRange: nil) as? NSMutableParagraphStyle {
                attributes.setObject(style, forKey: NSParagraphStyleAttributeName)
            }
        }
        
        let boundingRect = text.boundingRectWithSize(
            CGSize(width: boundingWidth, height: boundingHeight),
            options: options,
            attributes: attributes as [NSObject : AnyObject],
            context: nil
        )
        
        return boundingRect.size
    }
}