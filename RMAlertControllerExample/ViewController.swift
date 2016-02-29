//
//  ViewController.swift
//  RMAlertControllerExample
//
//  Created by Daniel Langh on 26/02/16.
//  Copyright © 2016 rumori. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showActionSheet() {
        let viewController = ActionSheetController()
        viewController.addAction(ActionSheetAction(title: "1", type: .Default, handler: { (action) -> Void in
            print(action.title)
        }))
        viewController.addAction(ActionSheetAction(title: "2", type: .Destructive, handler: { (action) -> Void in
            print(action.title)
        }))
        viewController.addAction(ActionSheetAction(title: "Cancel", type: .Cancel, handler: { (action) -> Void in
            print(action.title)
        }))
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    @IBAction func showAlert() {
        let viewController = AlertViewController()
        self.presentViewController(viewController, animated: true, completion: nil)
    }

    @IBAction func showTextAlert() {
        let viewController = TextAlertViewController()
        self.presentViewController(viewController, animated: true, completion: nil)
    }
}

