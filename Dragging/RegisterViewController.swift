//
//  RegisterViewController.swift
//  Dragging
//
//  Created by francis gallagher on 22/02/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var emailTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        // Defining the user object
        let user = PFUser()
        user.username = emailTextView.text
        user.email = emailTextView.text
        user.password = passwordTextView.text
        
        // Signing up using the Parse API
        user.signUpInBackground {
            (success, error) -> Void in
            if let error = error as NSError? {
                let errorString = error.userInfo["error"] as? NSString
                // In case something went wrong, use errorString to get the error
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
