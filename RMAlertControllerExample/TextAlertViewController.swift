//
//  TextAlertViewController.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 26/02/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

class TextAlertViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView:UITextView?
    @IBOutlet weak var textViewHeightConstraint:NSLayoutConstraint?
    
    let minimumTextHeight:CGFloat = 65.0
    let maximumTextHeight:CGFloat = 150.0
    
    let transitionDelegate:UIViewControllerTransitioningDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.transitionDelegate = AlertTransition()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.transitioningDelegate = self.transitionDelegate
        self.modalPresentationStyle = .Custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.textView?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.textView?.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateTextViewScrolling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateTextViewScrolling()
    }
    
    
    // MARK:
    
    func textViewDidChange(textView: UITextView) {
        self.updateTextViewScrolling()
    }

    // MARK:
    
    func updateTextViewScrolling() {
        guard let textView = self.textView else {
            return
        }
        
        let textHeight = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.max)).height
        
        let textViewHeight = min(maximumTextHeight, max(minimumTextHeight, textHeight))
        let shouldScroll = (textViewHeight < textHeight)
        
        if textView.scrollEnabled != shouldScroll {
            textView.scrollEnabled = shouldScroll
        }
        self.textViewHeightConstraint?.constant = textViewHeight
    }

    
    // MARK: User actions
    
    @IBAction func resign() {
        self.textView?.resignFirstResponder()
    }
    
    @IBAction func close() {
        self.resignFirstResponder()
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
