//
//  CustomTextActionSheetController.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 09/03/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit
import OAStackView

public class CustomTextActionSheetController: UIViewController {

    let cornerRadius:CGFloat = 15.0
    let sectionSpacing:CGFloat = 2.0
    
    var titleColor:UIColor = UIColor.lightGrayColor()
    var messageColor:UIColor = UIColor.lightGrayColor()
    
    var titleFont:UIFont = UIFont.boldSystemFontOfSize(13.0)
    var messageFont:UIFont = UIFont.systemFontOfSize(13.0)
    var itemTitleFont:UIFont = UIFont.systemFontOfSize(19.0)
    var itemSubtitleFont:UIFont = UIFont.systemFontOfSize(11.0)
    var cancelTitleFont:UIFont = UIFont.boldSystemFontOfSize(19.0)
    var separatorColor:UIColor = UIColor(white: 0.9, alpha: 1.0)
    
    var itemDestructiveTextColor:UIColor = UIColor.redColor()
    var itemTitleTextColor:UIColor? = nil
    
    var stackView:OAStackView? {
        return self.isViewLoaded() ? (self.view as? OAStackView) : nil
    }
    
    var message:String?
    
    var actions:Array<RMActionSheetAction> = []
    var cancelAction:RMActionSheetAction?
    
    var actionSheetTransition:RMActionSheetTransition
    
    init(title:String, message:String) {

        self.actionSheetTransition = RMActionSheetTransition()
        
        super.init(nibName: nil, bundle: nil)
        
        self.message = message
        self.title = title
        
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = actionSheetTransition
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:
    
    func addAction(action:RMActionSheetAction) {
        switch action.type {
        case .Cancel:
            self.cancelAction = action
        default:
            self.actions.append(action)
        }
    }
    
    // MARK:
    
    override public func loadView() {
        let view = OAStackView()
        view.axis = .Vertical
        view.spacing = sectionSpacing
        self.view = view
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.stackView?.addArrangedSubview(self.createButtonView())
        
        if let cancelAction = self.cancelAction {
            self.stackView?.addArrangedSubview(self.createCancelButton(cancelAction))
        }
    }
    
    func createCancelButton(action:RMActionSheetAction) -> UIButton {
        let button = UIButton(type: .System)
        button.setTitle(action.title, forState: .Normal)
        button.titleLabel?.font = self.cancelTitleFont
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = cornerRadius
        button.addTarget(self, action: #selector(CustomTextActionSheetController.cancel), forControlEvents: .TouchUpInside)
        return button
    }
    
    func createButtonView() -> UIView {
        
        let view = UIView()
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        
        let buttonStackView = OAStackView()
        buttonStackView.axis = .Vertical
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        view.addConstraints([
            NSLayoutConstraint(item: buttonStackView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: buttonStackView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: buttonStackView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: buttonStackView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
            ])
        
        let titleView = self.createTitleView(self.title, message:self.message)
        titleView.addConstraint(NSLayoutConstraint(item: titleView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 150.0))
        buttonStackView.addArrangedSubview(titleView)
        let separator = RMSeparatorView()
        separator.lineColor = self.separatorColor
        buttonStackView.addArrangedSubview(separator)
        
        var counter = 0
        for (index, action) in self.actions.enumerate() {
            let button = UIButton(type: .System)
            button.titleLabel?.numberOfLines = 0
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.Center
            var attributes = [NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName: self.itemTitleFont]
            if action.type == .Destructive {
                attributes[NSForegroundColorAttributeName] = self.itemDestructiveTextColor
            } else {
                if let itemTitleTextColor = self.itemTitleTextColor {
                    attributes[NSForegroundColorAttributeName] = itemTitleTextColor
                }
            }
            
            let attributedString = NSMutableAttributedString(string: action.title, attributes: attributes)
            if let subtitle = action.subtitle {
                attributedString.appendAttributedString(NSAttributedString(string: "\n"))
                let range = NSMakeRange(attributedString.length, subtitle.characters.count)
                attributedString.appendAttributedString(NSAttributedString(string: subtitle))
                attributes[NSFontAttributeName] = self.itemSubtitleFont
                attributedString.setAttributes(attributes, range: range)
            }
            
            button.setAttributedTitle(attributedString, forState: .Normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            button.backgroundColor = UIColor.whiteColor()
            if action.type == .Destructive {
                button.setTitleColor(UIColor.redColor(), forState: .Normal)
            }
            button.addTarget(self, action: #selector(CustomTextActionSheetController.itemTapped(_:)), forControlEvents: .TouchUpInside)
            buttonStackView.addArrangedSubview(button)
            
            if index < (self.actions.count-1) {
                let separator = RMSeparatorView()
                separator.lineColor = self.separatorColor
                buttonStackView.addArrangedSubview(separator)
            }
            
            button.tag = counter
            counter += 1
        }
        
        return view
    }
    
    func createTitleView(title:String?, message:String?) -> UIView {
        
        let titleView = UIView()
        titleView.backgroundColor = UIColor.whiteColor()
        return titleView
    }
    
    // MARK: User actions
    
    func itemTapped(button:UIButton) {
        let index = button.tag
        if index >= 0 && index < self.actions.count {
            let action = actions[index]
            action.handler(action)
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancel() {
        if let cancelAction = self.cancelAction {
            cancelAction.handler(cancelAction)
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                if let cancelAction = self.cancelAction {
                    cancelAction.handler(cancelAction)
                }
            })
        }
    }
}
