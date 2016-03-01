//
//  AlertSeparatorView.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 01/03/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit


@IBDesignable
class RMSeparatorView: UIView {
    
    @IBInspectable var lineColor:UIColor = UIColor.grayColor()
    
    override var opaque:Bool {
        set { /* prevent setting */ }
        get { return super.opaque }
    }
    override var backgroundColor:UIColor? {
        set { /* prevent setting */ }
        get { return super.backgroundColor }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSeparatorView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupSeparatorView()
    }
    
    func setupSeparatorView() {
        super.opaque = false
        self.userInteractionEnabled = false
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        
        let lineWidth:CGFloat = UIScreen.mainScreen().scale > 1.0 ? 0.5 : 1.0
        let lineRect = CGRect(origin: CGPoint.zero, size: CGSize(width: self.bounds.width, height: lineWidth))
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        CGContextSetFillColorWithColor(context, self.lineColor.CGColor)
        CGContextFillRect(context, lineRect)
    }
    
    override func intrinsicContentSize() -> CGSize {
        let lineWidth:CGFloat = UIScreen.mainScreen().scale > 1.0 ? 0.5 : 1.0
        let size = CGSize(width: self.bounds.width, height: lineWidth)
        return size
    }
}
