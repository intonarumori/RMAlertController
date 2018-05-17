//
//  ActionSheetTransition.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 26/02/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

// MARK: -

open class RMActionSheetTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {

    var transitionDuration:TimeInterval = 0.4
    var backgroundAlpha:CGFloat = 0.4
    var springDamping:CGFloat = 1.0
    var dismissEnabledWithBackgroundTap:Bool = true
    var backgroundFadeDurationPercent:Double = 0.4

    var horizontalPadding:CGFloat = 10.0
    var verticalPadding:CGFloat = 10.0
    
    var tapHandler:(() -> Void)?

    fileprivate var fadeView:UIView?
    fileprivate var isDismissing:Bool = false
    
    fileprivate weak var presentingViewController:UIViewController?
    fileprivate weak var presentedViewController:UIViewController?
    
    fileprivate weak var bottomConstraint:NSLayoutConstraint?
    
    // MARK:
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isDismissing = false
        self.presentingViewController = presenting
        self.presentedViewController = presented
        return self
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isDismissing = true
        return self
    }
    
    // MARK:
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        if isDismissing {
            
            let duration = self.transitionDuration(using: transitionContext)
            
            if let bottomConstraint = self.bottomConstraint,
                let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {

                let height = fromView.frame.height
                
                UIView.animate(
                    withDuration: duration,
                    delay: 0.0,
                    usingSpringWithDamping: springDamping,
                    initialSpringVelocity: 0.0,
                    options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                        bottomConstraint.constant = height + 10.0
                        containerView.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        transitionContext.completeTransition(finished)
                })
            }
            
            // animate fadeview
            
            let fadeDuration = duration * backgroundFadeDurationPercent
            
            let fadeView = self.fadeView
            UIView.animate(
                withDuration: fadeDuration,
                delay: 0.0,
                options: UIViewAnimationOptions.curveLinear,
                animations: { () -> Void in
                    fadeView?.alpha = 0.0
                },
                completion: nil)
            
            // animate tintcolors
            
            if let window = containerView.window {
                UIView.animate(withDuration: fadeDuration, animations: { () -> Void in
                    window.tintAdjustmentMode = .normal
                })
            }
            
        } else {
            
            if
                let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
                    
                    let fadeView = UIView(frame: containerView.bounds)
                    fadeView.backgroundColor = UIColor(white: 0.0, alpha: backgroundAlpha)
                    if dismissEnabledWithBackgroundTap {
                        fadeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RMActionSheetTransition.backgroundTapped(_:))))
                    }
                    fadeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    containerView.addSubview(fadeView)
                    self.fadeView = fadeView
                    
                    var fittingSize = UILayoutFittingCompressedSize
                    fittingSize.width = containerView.bounds.width - 2 * horizontalPadding
                    let size = toView.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: 1000, verticalFittingPriority: 750)
                    
                    toView.translatesAutoresizingMaskIntoConstraints = false
                    containerView.addSubview(toView)
                    
                    let bottomConstraint = NSLayoutConstraint(item: toView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -verticalPadding)
                    let leadingConstraint = NSLayoutConstraint(item: toView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: horizontalPadding)
                    let trailingConstraint = NSLayoutConstraint(item: toView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -horizontalPadding)
                    
                    bottomConstraint.constant = size.height
                    containerView.addConstraints([leadingConstraint, trailingConstraint, bottomConstraint])
                    containerView.layoutIfNeeded()
                    
                    self.bottomConstraint = bottomConstraint
                    
                    let duration = self.transitionDuration(using: transitionContext)
                    
                    UIView.animate(withDuration: duration,
                        delay: 0.0,
                        usingSpringWithDamping: springDamping,
                        initialSpringVelocity: 0.0,
                        options: UIViewAnimationOptions.curveEaseOut,
                        animations: { () -> Void in
                            bottomConstraint.constant = -self.verticalPadding
                            containerView.layoutIfNeeded()
                        }, completion: { (finished) -> Void in
                            transitionContext.completeTransition(finished)
                    })
                    
                    // animate fadeview
                    
                    let fadeDuration = duration * backgroundFadeDurationPercent
                    
                    fadeView.alpha = 0.0
                    UIView.animate(withDuration: fadeDuration,
                        delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                            fadeView.alpha = 1.0
                        }, completion: nil)
                    
                    // animate tintcolors
                    
                    if let window = containerView.window {
                        UIView.animate(withDuration: fadeDuration, animations: { () -> Void in
                            window.tintAdjustmentMode = .dimmed
                        })
                    }
                    containerView.tintAdjustmentMode = .normal
            }
        }
    }
    
    // MARK: User actions
    
    func backgroundTapped(_ tap:UITapGestureRecognizer) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
