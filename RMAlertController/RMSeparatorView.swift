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
    
    @IBInspectable var lineColor:UIColor = UIColor.gray
    
    override var isOpaque:Bool {
        set { /* prevent setting */ }
        get { return super.isOpaque }
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
        super.isOpaque = false
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        
        let lineWidth:CGFloat = UIScreen.main.scale > 1.0 ? 0.5 : 1.0
        let lineRect = CGRect(origin: CGPoint.zero, size: CGSize(width: self.bounds.width, height: lineWidth))
        if let context = UIGraphicsGetCurrentContext() {
            context.clear(rect)
            context.setFillColor(self.lineColor.cgColor)
            context.fill(lineRect)
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let lineWidth:CGFloat = UIScreen.main.scale > 1.0 ? 0.5 : 1.0
        let size = CGSize(width: self.bounds.width, height: lineWidth)
        return size
    }
}
