//
//  AlertController.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 26/02/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

enum ActionSheetActionType {
    case Default
    case Destructive
    case Cancel
}

class ActionSheetAction {
    let title:String
    let type:ActionSheetActionType
    let handler:(ActionSheetAction -> Void)
    
    init(title:String, type:ActionSheetActionType, handler:(ActionSheetAction -> Void)) {
        self.title = title
        self.type = type
        self.handler = handler
    }
}

// MARK: -

class ActionSheetController: UIViewController {

    let cornerRadius:CGFloat = 10.0
    let sectionSpacing:CGFloat = 3.0
    let itemSpacing:CGFloat = 0.5
    
    var stackView:OAStackView? {
        return self.isViewLoaded() ? (self.view as? OAStackView) : nil
    }
    
    var actions:Array<ActionSheetAction> = []
    var cancelAction:ActionSheetAction?
    
    var transitionDelegate:UIViewControllerTransitioningDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
        self.transitionDelegate = ActionSheetTransition()
        self.transitioningDelegate = self.transitionDelegate
        self.modalPresentationStyle = .Custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:
    
    func addAction(action:ActionSheetAction) {
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
    
    func createCancelButton(action:ActionSheetAction) -> UIButton {
        let button = UIButton(type: .System)
        button.setTitle(action.title, forState: .Normal)
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
        buttonStackView.spacing = itemSpacing
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        view.addConstraints([
            NSLayoutConstraint(item: buttonStackView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: buttonStackView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: buttonStackView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: buttonStackView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
            ])

        let titleView = UIView()
        titleView.backgroundColor = UIColor.whiteColor()

        let titleLabel = UILabel()
        titleLabel.textAlignment = .Center
        titleLabel.text = "Title of the sheet"

        let detailLabel = UILabel()
        detailLabel.textAlignment = .Center
        detailLabel.text = "Detail of the sheet"
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(titleLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(detailLabel)

        titleView.addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: titleView, attribute: .Top, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: titleView, attribute: .Leading, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: titleView, attribute: .Trailing, multiplier: 1.0, constant: -10.0)
            ])
        titleView.addConstraints([
            NSLayoutConstraint(item: detailLabel, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1.0, constant: 5.0),
            NSLayoutConstraint(item: detailLabel, attribute: .Bottom, relatedBy: .Equal, toItem: titleView, attribute: .Bottom, multiplier: 1.0, constant: -10.0),
            NSLayoutConstraint(item: detailLabel, attribute: .Leading, relatedBy: .Equal, toItem: titleView, attribute: .Leading, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: detailLabel, attribute: .Trailing, relatedBy: .Equal, toItem: titleView, attribute: .Trailing, multiplier: 1.0, constant: -10.0)
            ])
        
        buttonStackView.addArrangedSubview(titleView)
        
        var counter = 0
        for action in self.actions {
            let button = UIButton(type: .System)
            button.tag = counter
            button.setTitle(action.title, forState: .Normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            button.backgroundColor = UIColor.whiteColor()
            if action.type == .Destructive {
                button.setTitleColor(UIColor.redColor(), forState: .Normal)
            }
            button.addTarget(self, action: Selector("itemTapped:"), forControlEvents: .TouchUpInside)
            buttonStackView.addArrangedSubview(button)
            
            counter += 1
        }

        return view
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
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
