//
//  UILabelExtension.swift
//

import UIKit

extension UILabel {
    func fontSizeToFit(_ minFontSize: CGFloat) {
        if self.text == nil {
            return
        }
        
        let maxLines = self.numberOfLines == 0 ? Int.max : self.numberOfLines
        
        var bestFont = self.font!
        let words = self.text!.components(separatedBy: .whitespacesAndNewlines)
        for word in words {
            let minFont = fontSizeToFitCalculateMinFontForSubText(" \(word) ", minFontSize: minFontSize, maxLines: 1)
            if minFont.pointSize < bestFont.pointSize {
                bestFont = minFont
            }
        }
        
        let minTextFont = fontSizeToFitCalculateMinFontForSubText(text!, minFontSize: minFontSize, maxLines: maxLines)
        if minTextFont.pointSize < (bestFont.pointSize) {
            bestFont = minTextFont
        }
        
        self.font = bestFont
    }
    
    func fontSizeToFit() {
        fontSizeToFit(0.0)
    }
    
    private func fontSizeToFitCalculateMinFontForSubText(_ text: String, minFontSize: CGFloat, maxLines: Int) -> UIFont {
        let maxHeight = self.bounds.height

        var testFont = self.font
        var size = fontSizeTofitCalculateSizeForFont(testFont!, text: text)
        
        while maxHeight < size.height || CGFloat(maxLines) < floor(size.height / (testFont?.pointSize)!) {
            testFont = testFont?.withSize((testFont?.pointSize)! - 0.5)
            size = fontSizeTofitCalculateSizeForFont(testFont!, text: text)
            if (testFont?.pointSize)! < minFontSize {
                break;
            }
        }
        
        return testFont!
    }
    
    private func fontSizeTofitCalculateSizeForFont(_ font: UIFont, text: String) -> CGSize {
        
        let boundingWidth = self.bounds.width
        let boundingHeight = CGFloat.greatestFiniteMagnitude
        let options = unsafeBitCast(
            NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.usesFontLeading.rawValue,
            to: NSStringDrawingOptions.self
        )
        
        var attributes:[NSAttributedString.Key : Any] = [NSAttributedString.Key.font: font]
        if let concreteAttributedText = self.attributedText {
            if let kern = concreteAttributedText.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: nil) as? CGFloat {
                attributes[NSAttributedString.Key.kern] = kern
            }
            
            if let style = concreteAttributedText.attribute(NSAttributedString.Key.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle {
                attributes[NSAttributedString.Key.paragraphStyle] = style
            }
        }
        
        let boundingRect = text.boundingRect(
            with: CGSize(width: boundingWidth, height: boundingHeight),
            options: options,
            attributes: attributes ,
            context: nil
        )
        
        return boundingRect.size
    }
}
