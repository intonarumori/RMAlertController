//
//  CustomActionSheetController.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 01/03/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

public enum RMActionSheetActionType {
    case `default`
    case destructive
    case cancel
}

open class RMActionSheetAction {
    let title:String
    let subtitle:String?
    let type:RMActionSheetActionType
    let handler:((RMActionSheetAction) -> Void)
    
    init(title:String, subtitle:String?, type:RMActionSheetActionType, handler:@escaping ((RMActionSheetAction) -> Void)) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.handler = handler
    }
}

// MARK: -

open class RMActionSheetController: UIViewController, UIViewControllerTransitioningDelegate {

    let cornerRadius:CGFloat = 15.0
    let sectionSpacing:CGFloat = 8.0
    
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
    
    var stackView: UIStackView? {
        return self.isViewLoaded ? (self.view as? UIStackView) : nil
    }
    
    var actionSheetTransition: RMActionSheetTransition
    
    var message:String?
    
    var actions:Array<RMActionSheetAction> = []
    var cancelAction:RMActionSheetAction?
    
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
        let view = UIStackView()
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
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }
    
    func createButtonView() -> UIView {
        
        let view = UIView()
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        
        let buttonStackView = UIStackView()
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
            var attributes: [NSAttributedStringKey: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: self.itemTitleFont
            ]
            if action.type == .destructive {
                attributes[.foregroundColor] = self.itemDestructiveTextColor
            } else {
                if let itemTitleTextColor = self.itemTitleTextColor {
                    attributes[.foregroundColor] = itemTitleTextColor
                }
            }
            
            let attributedString = NSMutableAttributedString(string: action.title, attributes: attributes)
            if let subtitle = action.subtitle {
                attributedString.append(NSAttributedString(string: "\n"))
                let range = NSMakeRange(attributedString.length, subtitle.count)
                attributedString.append(NSAttributedString(string: subtitle))
                attributes[.font] = self.itemSubtitleFont
                attributedString.setAttributes(attributes, range: range)
            }
            
            button.setAttributedTitle(attributedString, for: UIControlState())
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            button.backgroundColor = UIColor.white
            if action.type == .destructive {
                button.setTitleColor(UIColor.red, for: UIControlState())
            }
            button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
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

        let gap:CGFloat = 0.0
        let verticalPadding:CGFloat = 13.0
        let horizontalPadding:CGFloat = 10.0
        
        let titleView = UIView()
        titleView.backgroundColor = UIColor.white
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = self.titleColor
        titleLabel.font = self.titleFont
        titleLabel.text = title
        
        let detailLabel = UILabel()
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.textColor = self.messageColor
        detailLabel.font = self.messageFont
        detailLabel.text = message
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(titleLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(detailLabel)
        
        titleView.addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: titleView, attribute: .top, multiplier: 1.0, constant: verticalPadding),
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: titleView, attribute: .leading, multiplier: 1.0, constant: horizontalPadding),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: titleView, attribute: .trailing, multiplier: 1.0, constant: -horizontalPadding),
            NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: titleView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            ])
        titleView.addConstraints([
            NSLayoutConstraint(item: detailLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: gap),
            NSLayoutConstraint(item: detailLabel, attribute: .bottom, relatedBy: .equal, toItem: titleView, attribute: .bottom, multiplier: 1.0, constant: -verticalPadding),
            NSLayoutConstraint(item: detailLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: titleView, attribute: .leading, multiplier: 1.0, constant: horizontalPadding),
            NSLayoutConstraint(item: detailLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: titleView, attribute: .trailing, multiplier: 1.0, constant: -horizontalPadding),
            NSLayoutConstraint(item: detailLabel, attribute: .centerX, relatedBy: .equal, toItem: titleView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            ])

        return titleView
    }
    
    // MARK: User actions
    
    @objc func itemTapped(_ button:UIButton) {
        let index = button.tag
        if index >= 0 && index < self.actions.count {
            let action = actions[index]
            action.handler(action)
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
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

