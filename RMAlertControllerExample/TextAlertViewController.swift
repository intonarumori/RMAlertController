//
//  TextAlertViewController.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 26/02/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

class TextAlertViewController: UIViewController {

    @IBOutlet weak var textView:UITextView?
    
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
    
    // MARK: User actions
    
    @IBAction func resign() {
        self.textView?.resignFirstResponder()
    }
    
    @IBAction func close() {
        self.resignFirstResponder()
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
