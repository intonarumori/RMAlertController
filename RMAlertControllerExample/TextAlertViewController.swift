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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewwillappear")
        super.viewWillAppear(animated)
        self.textView?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("viewwilldisapper")
        super.viewWillDisappear(animated)
        self.textView?.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
