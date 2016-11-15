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
    
    let alertTransition = RMAlertTransition()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.transitioningDelegate = alertTransition
        self.modalPresentationStyle = .custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    func textViewDidChange(_ textView: UITextView) {
        self.updateTextViewScrolling()
    }

    // MARK:
    
    func updateTextViewScrolling() {
        guard let textView = self.textView else {
            return
        }
        
        let textHeight = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
        
        let textViewHeight = min(maximumTextHeight, max(minimumTextHeight, textHeight))
        let shouldScroll = (textViewHeight < textHeight)
        
        if textView.isScrollEnabled != shouldScroll {
            textView.isScrollEnabled = shouldScroll
        }
        self.textViewHeightConstraint?.constant = textViewHeight
    }

    
    // MARK: User actions
    
    @IBAction func resign() {
        self.textView?.resignFirstResponder()
    }
    
    @IBAction func close() {
        self.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
