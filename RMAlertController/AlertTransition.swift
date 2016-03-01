//
//  AlertTransition.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 26/02/16.
//  Copyright © 2016 rumori. All rights reserved.
//

//
//  ActionSheetTransition.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 26/02/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

public class AlertTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    var showDuration:NSTimeInterval = 0.5
    var hideDuration:NSTimeInterval = 0.3
    
    var backgroundAlpha:CGFloat = 0.4
    var springDamping:CGFloat = 0.7
    var dismissEnabledWithBackgroundTap:Bool = false
    var backgroundFadeDurationPercent:Double = 0.4
    
    var minimumWidth:CGFloat = 250.0
    var maximumWidth:CGFloat = 350.0
    
    var horizontalPadding:CGFloat = 20.0
    var verticalPadding:CGFloat = 20.0

    private var fadeView:UIView?
    private var contentView:UIView?

    private var isDismissing:Bool = false
    
    private weak var presentedViewController:UIViewController?
    private weak var presentingViewController:UIViewController?
    private weak var containerView:UIView?
    
    private var centerYConstraint:NSLayoutConstraint?
    private var bottomConstraint:NSLayoutConstraint?
    private var centerYConstant:CGFloat = 0.0
    private var bottomConstant:CGFloat = 0.0
    
    override init() {
        super.init()
        self.addObservers()
        self.bottomConstant = verticalPadding
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK:
    
    func keyboardWillShow(notification:NSNotification) {
        
        if let endFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            let height = endFrame.height
            centerYConstant = -height / 2.0
            bottomConstant = height + verticalPadding
            
            if let
                centerYConstraint = self.centerYConstraint,
                bottomConstraint = self.bottomConstraint {
                    
                centerYConstraint.constant = centerYConstant
                bottomConstraint.constant = bottomConstant
                UIView.animateWithDuration(0.33, animations: { () -> Void in
                    self.containerView?.layoutIfNeeded()
                })
            }
        }
    }

    func keyboardWillHide(notification:NSNotification) {

        centerYConstant = 0.0
        bottomConstant = verticalPadding

        if
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double,
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
        let centerYConstraint = self.centerYConstraint,
        let bottomConstraint = self.bottomConstraint {

            bottomConstraint.constant = bottomConstant
            centerYConstraint.constant = centerYConstant
                
            UIView.animateWithDuration(duration,
                delay: 0,
                options: UIViewAnimationOptions(rawValue: curve),
                animations: {
                    self.containerView?.layoutIfNeeded()
                },
                completion:nil)
        }
    }

    
    // MARK:
    
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
        return self.isDismissing ? hideDuration : showDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        self.containerView = containerView
        
        if isDismissing {
            
            if let contentView = self.contentView {
                
                let duration = self.transitionDuration(transitionContext)

                UIView.animateWithDuration(duration,
                    delay:0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: { () -> Void in
                        
                        contentView.transform = CGAffineTransformMakeTranslation(0, containerView.bounds.height/2.0 + contentView.bounds.height/2.0)
                    }, completion: { (finished) -> Void in
                        transitionContext.completeTransition(finished)
                })

                // animate fadeview
            
                let fadeView = self.fadeView
                let fadeDuration = self.transitionDuration(transitionContext) * backgroundFadeDurationPercent
                let fadeDelay = duration - fadeDuration
                UIView.animateWithDuration(
                    fadeDuration,
                    delay: fadeDelay,
                    options: UIViewAnimationOptions.CurveLinear,
                    animations: { () -> Void in
                        fadeView?.alpha = 0.0
                    },
                    completion: nil)
                
                // animate tintcolors
                
                if let window = containerView.window {
                    UIView.animateWithDuration(
                        fadeDuration,
                        animations: { () -> Void in
                            window.tintAdjustmentMode = .Normal
                        })
                }
            }
        
        } else {
            
            if
                let toView = transitionContext.viewForKey(UITransitionContextToViewKey) {
                    
                    // Create fadeview
                    
                    let fadeView = UIView(frame: containerView.bounds)
                    fadeView.backgroundColor = UIColor(white: 0.0, alpha: backgroundAlpha)
                    if dismissEnabledWithBackgroundTap {
                        fadeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("backgroundTapped:")))
                    }
                    fadeView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                    containerView.addSubview(fadeView)
                    self.fadeView = fadeView
                    
                    // Create contentview
                    
                    let contentView = UIView()
                    contentView.layer.cornerRadius = 10.0
                    contentView.clipsToBounds = true


                    // Add toview to contentview
                    
                    toView.translatesAutoresizingMaskIntoConstraints = false
                    contentView.addSubview(toView)
                    contentView.addConstraints([
                        NSLayoutConstraint(item: toView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
                        NSLayoutConstraint(item: toView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                        NSLayoutConstraint(item: toView, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                        NSLayoutConstraint(item: toView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
                        ])

                    
                    // Add contentview to container
                    
                    contentView.translatesAutoresizingMaskIntoConstraints = false
                    containerView.addSubview(contentView)
                    
                    let topConstraint = NSLayoutConstraint(item: contentView, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: self.verticalPadding)
                    let bottomConstraint = NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .LessThanOrEqual, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: self.bottomConstant)
                    let centerYConstraint = NSLayoutConstraint(item: contentView, attribute: .CenterY, relatedBy: .Equal, toItem: containerView, attribute: .CenterY, multiplier: 1.0, constant: self.centerYConstant)
                    centerYConstraint.priority = 750
                    let minimumWidthConstraint = NSLayoutConstraint(item: contentView, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.minimumWidth)
                    let maximumWidthConstraint = NSLayoutConstraint(item: contentView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.maximumWidth)
                    let centerXConstraint = NSLayoutConstraint(item: contentView, attribute: .CenterX, relatedBy: .Equal, toItem: containerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
                    let leadingConstraint = NSLayoutConstraint(item: contentView, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: containerView, attribute: .Leading, multiplier: 1.0, constant: horizontalPadding)
                    let trailingConstraint = NSLayoutConstraint(item: contentView, attribute: .Trailing, relatedBy: .LessThanOrEqual, toItem: containerView, attribute: .Trailing, multiplier: 1.0, constant: -horizontalPadding)
                    containerView.addConstraints([leadingConstraint, trailingConstraint, centerYConstraint, topConstraint, bottomConstraint, centerXConstraint, minimumWidthConstraint, maximumWidthConstraint])
                    self.contentView = contentView
                    self.centerYConstraint = centerYConstraint
                    self.bottomConstraint = bottomConstraint
                    
                    
                    // Animate appearances
                    
                    let duration = self.transitionDuration(transitionContext)
                    
                    contentView.transform = CGAffineTransformMakeScale(0.2, 0.2)
                    UIView.animateWithDuration(
                        duration,
                        delay: 0.0,
                        usingSpringWithDamping: springDamping,
                        initialSpringVelocity: 0.0,
                        options: UIViewAnimationOptions.CurveEaseOut,
                        animations: { () -> Void in
                            contentView.transform = CGAffineTransformIdentity
                        }, completion: { (finished) -> Void in
                            transitionContext.completeTransition(finished)
                        })
                    
                    // animate fadeview

                    let fadeDuration = duration * backgroundFadeDurationPercent

                    fadeView.alpha = 0.0
                    UIView.animateWithDuration(
                        fadeDuration,
                        delay: 0.0,
                        options: UIViewAnimationOptions.CurveLinear,
                        animations: { () -> Void in
                            fadeView.alpha = 1.0
                        },
                        completion: nil)
                    
                    // animate tintcolors
                    
                    if let window = containerView.window {
                        UIView.animateWithDuration(
                            fadeDuration,
                            animations: { () -> Void in
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