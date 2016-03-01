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
    
    // MARK: -
    
    @IBAction func showNativeActionSheet() {
    
        let actionController = UIAlertController(title: "Title", message: "Message", preferredStyle: .ActionSheet)
        actionController.addAction(UIAlertAction(title: "First option", style: .Default, handler: { (action) -> Void in
            print(action.title)
        }))
        actionController.addAction(UIAlertAction(title: "Second option", style: .Destructive, handler: { (action) -> Void in
            print(action.title)
        }))
        actionController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            print(action.title)
        }))
        self.presentViewController(actionController, animated: true, completion: nil)
    }
    
    @IBAction func showActionSheet() {
        let viewController = CustomActionSheetController(title: "Title", message: "Message")
        viewController.addAction(CustomActionSheetAction(title: "First option", subtitle: nil, type: .Default, handler: { (action) -> Void in
            print(action.title)
        }))
        viewController.addAction(CustomActionSheetAction(title: "Second option", subtitle: nil, type: .Destructive, handler: { (action) -> Void in
            print(action.title)
        }))
        viewController.addAction(CustomActionSheetAction(title: "Cancel", subtitle: nil, type: .Cancel, handler: { (action) -> Void in
            print(action.title)
        }))
        self.presentViewController(viewController, animated: true, completion: nil)
    }

    @IBAction func showCustomActionSheet() {
        let viewController = CustomActionSheetController(title: "Title", message: "Message")
        viewController.addAction(CustomActionSheetAction(title: "First option", subtitle: "First option subtitle", type: .Default, handler: { (action) -> Void in
            print(action.title)
        }))
        viewController.addAction(CustomActionSheetAction(title: "Second option", subtitle: "Second option subtitle", type: .Destructive, handler: { (action) -> Void in
            print(action.title)
        }))
        viewController.addAction(CustomActionSheetAction(title: "Cancel", subtitle: nil, type: .Cancel, handler: { (action) -> Void in
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

