//
//  AlertViewController.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 26/02/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    let transitionDelegate:UIViewControllerTransitioningDelegate
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.transitionDelegate = RMAlertTransition()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.transitioningDelegate = self.transitionDelegate
        self.modalPresentationStyle = .Custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapped() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
