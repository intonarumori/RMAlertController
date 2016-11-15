//
//  CustomTextActionSheetController.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 09/03/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit
import OAStackView

open class CustomTextActionSheetController: UIViewController {

    let cornerRadius:CGFloat = 15.0
    let sectionSpacing:CGFloat = 2.0
    
    var titleColor:UIColor = UIColor.lightGray
    var messageColor:UIColor = UIColor.lightGray
    
    var titleFont:UIFont = UIFont.boldSystemFont(ofSize: 13.0)
    var messageFont:UIFont = UIFont.systemFont(ofSize: 13.0)
    var itemTitleFont:UIFont = UIFont.systemFont(ofSize: 19.0)
    var itemSubtitleFont:UIFont = UIFont.systemFont(ofSize: 11.0)
    var cancelTitleFont:UIFont = UIFont.boldSystemFont(ofSize: 19.0)
    var separatorColor:UIColor = UIColor(white: 0.9, alpha: 1.0)
    
    var itemDestructiveTextColor:UIColor = UIColor.red
    var itemTitleTextColor:UIColor? = nil
    
    var stackView:OAStackView? {
        return self.isViewLoaded ? (self.view as? OAStackView) : nil
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
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = actionSheetTransition
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:
    
    func addAction(_ action:RMActionSheetAction) {
        switch action.type {
        case .cancel:
            self.cancelAction = action
        default:
            self.actions.append(action)
        }
    }
    
    // MARK:
    
    override open func loadView() {
        let view = OAStackView()
        view.axis = .vertical
        view.spacing = sectionSpacing
        self.view = view
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.stackView?.addArrangedSubview(self.createButtonView())
        
        if let cancelAction = self.cancelAction {
            self.stackView?.addArrangedSubview(self.createCancelButton(cancelAction))
        }
    }
    
    func createCancelButton(_ action:RMActionSheetAction) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(action.title, for: UIControlState())
        button.titleLabel?.font = self.cancelTitleFont
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = cornerRadius
        button.addTarget(self, action: #selector(CustomTextActionSheetController.cancel), for: .touchUpInside)
        return button
    }
    
    func createButtonView() -> UIView {
        
        let view = UIView()
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        
        let buttonStackView = OAStackView()
        buttonStackView.axis = .vertical
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        view.addConstraints([
            NSLayoutConstraint(item: buttonStackView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: buttonStackView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: buttonStackView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: buttonStackView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            ])
        
        let titleView = self.createTitleView(self.title, message:self.message)
        titleView.addConstraint(NSLayoutConstraint(item: titleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150.0))
        buttonStackView.addArrangedSubview(titleView)
        let separator = RMSeparatorView()
        separator.lineColor = self.separatorColor
        buttonStackView.addArrangedSubview(separator)
        
        var counter = 0
        for (index, action) in self.actions.enumerated() {
            let button = UIButton(type: .system)
            button.titleLabel?.numberOfLines = 0
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center
            var attributes = [NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName: self.itemTitleFont] as [String : Any]
            if action.type == .destructive {
                attributes[NSForegroundColorAttributeName] = self.itemDestructiveTextColor
            } else {
                if let itemTitleTextColor = self.itemTitleTextColor {
                    attributes[NSForegroundColorAttributeName] = itemTitleTextColor
                }
            }
            
            let attributedString = NSMutableAttributedString(string: action.title, attributes: attributes)
            if let subtitle = action.subtitle {
                attributedString.append(NSAttributedString(string: "\n"))
                let range = NSMakeRange(attributedString.length, subtitle.characters.count)
                attributedString.append(NSAttributedString(string: subtitle))
                attributes[NSFontAttributeName] = self.itemSubtitleFont
                attributedString.setAttributes(attributes, range: range)
            }
            
            button.setAttributedTitle(attributedString, for: UIControlState())
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            button.backgroundColor = UIColor.white
            if action.type == .destructive {
                button.setTitleColor(UIColor.red, for: UIControlState())
            }
            button.addTarget(self, action: #selector(CustomTextActionSheetController.itemTapped(_:)), for: .touchUpInside)
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
    
    func createTitleView(_ title:String?, message:String?) -> UIView {
        
        let titleView = UIView()
        titleView.backgroundColor = UIColor.white
        return titleView
    }
    
    // MARK: User actions
    
    func itemTapped(_ button:UIButton) {
        let index = button.tag
        if index >= 0 && index < self.actions.count {
            let action = actions[index]
            action.handler(action)
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func cancel() {
        if let cancelAction = self.cancelAction {
            cancelAction.handler(cancelAction)
            self.presentingViewController?.dismiss(animated: true, completion: { () -> Void in
                if let cancelAction = self.cancelAction {
                    cancelAction.handler(cancelAction)
                }
            })
        }
    }
}
