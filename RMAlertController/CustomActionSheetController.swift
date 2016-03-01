//
//  CustomActionSheetController.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 01/03/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

enum CustomActionSheetActionType {
    case Default
    case Destructive
    case Cancel
}

class CustomActionSheetAction {
    let title:String
    let subtitle:String?
    let type:CustomActionSheetActionType
    let handler:(CustomActionSheetAction -> Void)
    
    init(title:String, subtitle:String?, type:CustomActionSheetActionType, handler:(CustomActionSheetAction -> Void)) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.handler = handler
    }
}

class CustomActionSheetController: UIViewController {

    let cornerRadius:CGFloat = 15.0
    let sectionSpacing:CGFloat = 8.0
    
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
    
    var actions:Array<CustomActionSheetAction> = []
    var cancelAction:CustomActionSheetAction?
    
    var transitionDelegate:UIViewControllerTransitioningDelegate?
    
    init(title:String, message:String) {
        super.init(nibName: nil, bundle: nil)
        
        self.message = message
        self.title = title
        
        self.transitionDelegate = ActionSheetTransition()
        self.transitioningDelegate = self.transitionDelegate
        self.modalPresentationStyle = .Custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:
    
    func addAction(action:CustomActionSheetAction) {
        switch action.type {
        case .Cancel:
            self.cancelAction = action
        default:
            self.actions.append(action)
        }
    }
    
    // MARK:
    
    override func loadView() {
        let view = OAStackView()
        view.axis = .Vertical
        view.spacing = sectionSpacing
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stackView?.addArrangedSubview(self.createButtonView())
        
        if let cancelAction = self.cancelAction {
            self.stackView?.addArrangedSubview(self.createCancelButton(cancelAction))
        }
    }
    
    func createCancelButton(action:CustomActionSheetAction) -> UIButton {
        let button = UIButton(type: .System)
        button.setTitle(action.title, forState: .Normal)
        button.titleLabel?.font = self.cancelTitleFont
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = cornerRadius
        button.addTarget(self, action: Selector("cancel"), forControlEvents: .TouchUpInside)
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
        buttonStackView.addArrangedSubview(titleView)
        let separator = AlertSeparatorView()
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
            button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            button.backgroundColor = UIColor.whiteColor()
            if action.type == .Destructive {
                button.setTitleColor(UIColor.redColor(), forState: .Normal)
            }
            button.addTarget(self, action: Selector("itemTapped:"), forControlEvents: .TouchUpInside)
            buttonStackView.addArrangedSubview(button)

            if index < (self.actions.count-1) {
                let separator = AlertSeparatorView()
                separator.lineColor = self.separatorColor
                buttonStackView.addArrangedSubview(separator)
            }
            
            button.tag = counter
            counter += 1
        }
        
        return view
    }
    
    func createTitleView(title:String?, message:String?) -> UIView {

        let gap:CGFloat = 0.0
        let verticalPadding:CGFloat = 13.0
        let horizontalPadding:CGFloat = 10.0
        
        let titleView = UIView()
        titleView.backgroundColor = UIColor.whiteColor()
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .Center
        titleLabel.textColor = self.titleColor
        titleLabel.font = self.titleFont
        titleLabel.text = title
        
        let detailLabel = UILabel()
        detailLabel.textAlignment = .Center
        detailLabel.numberOfLines = 0
        detailLabel.textColor = self.messageColor
        detailLabel.font = self.messageFont
        detailLabel.text = message
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(titleLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(detailLabel)
        
        titleView.addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: titleView, attribute: .Top, multiplier: 1.0, constant: verticalPadding),
            NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: titleView, attribute: .Leading, multiplier: 1.0, constant: horizontalPadding),
            NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .LessThanOrEqual, toItem: titleView, attribute: .Trailing, multiplier: 1.0, constant: -horizontalPadding),
            NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: titleView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            ])
        titleView.addConstraints([
            NSLayoutConstraint(item: detailLabel, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1.0, constant: gap),
            NSLayoutConstraint(item: detailLabel, attribute: .Bottom, relatedBy: .Equal, toItem: titleView, attribute: .Bottom, multiplier: 1.0, constant: -verticalPadding),
            NSLayoutConstraint(item: detailLabel, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: titleView, attribute: .Leading, multiplier: 1.0, constant: horizontalPadding),
            NSLayoutConstraint(item: detailLabel, attribute: .Trailing, relatedBy: .LessThanOrEqual, toItem: titleView, attribute: .Trailing, multiplier: 1.0, constant: -horizontalPadding),
            NSLayoutConstraint(item: detailLabel, attribute: .CenterX, relatedBy: .Equal, toItem: titleView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            ])

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

