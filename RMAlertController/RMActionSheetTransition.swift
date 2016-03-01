//
//  ActionSheetTransition.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 26/02/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

public class RMActionSheetTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

    var transitionDuration:NSTimeInterval = 0.4
    var backgroundAlpha:CGFloat = 0.4
    var springDamping:CGFloat = 1.0
    var dismissEnabledWithBackgroundTap:Bool = true
    var backgroundFadeDurationPercent:Double = 0.4

    var horizontalPadding:CGFloat = 10.0
    var verticalPadding:CGFloat = 10.0

    private var fadeView:UIView?
    private var isDismissing:Bool = false
    
    private weak var presentedViewController:UIViewController?
    private weak var presentingViewController:UIViewController?
    private weak var bottomConstraint:NSLayoutConstraint?
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isDismissing = false
        self.presentedViewController = presented
        self.presentingViewController = presenting
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isDismissing = true
        self.presentedViewController = nil
        self.presentingViewController = nil
        return self
    }
    
    // MARK:
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return transitionDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        if isDismissing {
            
            let duration = self.transitionDuration(transitionContext)
            
            if let
                bottomConstraint = self.bottomConstraint,
                fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) {

                let height = fromView.frame.height
                
                UIView.animateWithDuration(
                    duration,
                    delay: 0.0,
                    usingSpringWithDamping: springDamping,
                    initialSpringVelocity: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                        bottomConstraint.constant = height + 10.0
                        containerView.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        transitionContext.completeTransition(finished)
                })
            }
            
            // animate fadeview
            
            let fadeDuration = duration * backgroundFadeDurationPercent
            
            let fadeView = self.fadeView
            UIView.animateWithDuration(
                fadeDuration,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveLinear,
                animations: { () -> Void in
                    fadeView?.alpha = 0.0
                },
                completion: nil)
            
            // animate tintcolors
            
            if let window = containerView.window {
                UIView.animateWithDuration(fadeDuration, animations: { () -> Void in
                    window.tintAdjustmentMode = .Normal
                })
            }
            
        } else {
            
            if
                let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {
                    
                    let fadeView = UIView(frame: containerView.bounds)
                    fadeView.backgroundColor = UIColor(white: 0.0, alpha: backgroundAlpha)
                    if dismissEnabledWithBackgroundTap {
                        fadeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("backgroundTapped:")))
                    }
                    fadeView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                    containerView.addSubview(fadeView)
                    self.fadeView = fadeView
                    
                    var fittingSize = UILayoutFittingCompressedSize
                    fittingSize.width = containerView.bounds.width - 2 * horizontalPadding
                    let size = toView.systemLayoutSizeFittingSize(fittingSize, withHorizontalFittingPriority: 1000, verticalFittingPriority: 750)
                    
                    toView.translatesAutoresizingMaskIntoConstraints = false
                    containerView.addSubview(toView)
                    
                    let bottomConstraint = NSLayoutConstraint(item: toView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: -verticalPadding)
                    let leadingConstraint = NSLayoutConstraint(item: toView, attribute: .Leading, relatedBy: .Equal, toItem: containerView, attribute: .Leading, multiplier: 1.0, constant: horizontalPadding)
                    let trailingConstraint = NSLayoutConstraint(item: toView, attribute: .Trailing, relatedBy: .Equal, toItem: containerView, attribute: .Trailing, multiplier: 1.0, constant: -horizontalPadding)
                    
                    bottomConstraint.constant = size.height
                    containerView.addConstraints([leadingConstraint, trailingConstraint, bottomConstraint])
                    containerView.layoutIfNeeded()
                    
                    self.bottomConstraint = bottomConstraint
                    
                    let duration = self.transitionDuration(transitionContext)
                    
                    UIView.animateWithDuration(duration,
                        delay: 0.0,
                        usingSpringWithDamping: springDamping,
                        initialSpringVelocity: 0.0,
                        options: UIViewAnimationOptions.CurveEaseOut,
                        animations: { () -> Void in
                            bottomConstraint.constant = -self.verticalPadding
                            containerView.layoutIfNeeded()
                        }, completion: { (finished) -> Void in
                            transitionContext.completeTransition(finished)
                    })
                    
                    // animate fadeview
                    
                    let fadeDuration = duration * backgroundFadeDurationPercent
                    
                    fadeView.alpha = 0.0
                    UIView.animateWithDuration(fadeDuration,
                        delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                            fadeView.alpha = 1.0
                        }, completion: nil)
                    
                    // animate tintcolors
                    
                    if let window = containerView.window {
                        UIView.animateWithDuration(fadeDuration, animations: { () -> Void in
                            window.tintAdjustmentMode = .Dimmed
                        })
                    }
                    containerView.tintAdjustmentMode = .Normal
            }
        }
    }
    
    // MARK: User actions
    
    func backgroundTapped(tap:UITapGestureRecognizer) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
