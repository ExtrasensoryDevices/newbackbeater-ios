//
//  NibDesignable.swift
//
//  Copyright (c) 2014 Morten Bøgh
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

public class NibDesignable: UIView {
    
    
    var nibView:UIView!
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
        self.setup()
    }
    
    // MARK: - NSCoding
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
        self.setup()
    }
    
    // MARK: - Nib loading
    
    /**
    Called in init(frame:) and init(aDecoder:) to load the nib and add it as a subview.
    */
    private func setupNib() {
        nibView = self.loadNib()
        nibView.frame = self.bounds
        nibView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        nibView.backgroundColor = UIColor.clearColor()
        self.addSubview(nibView)
    }
    
    /**
    Called to load the nib in setupNib().
    
    :returns: UIView instance loaded from a nib file.
    */
    public func loadNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: self.nibName(), bundle: bundle)
        return nib.instantiateWithOwner(self, options: nil)[0] as! UIView
    }
    
    /**
    Called in the default implementation of loadNib(). Default is class name.
    
    :returns: Name of a single view nib file.
    */
    public func nibName() -> String {
        return self.dynamicType.description().componentsSeparatedByString(".").last!
    }
    
    /**
    Called in init(frame:) and init(aDecoder:). Override in children.
    */
    func setup() {
        // override in children
    }
}