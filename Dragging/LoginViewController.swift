//
//  LoginViewController.swift
//  Dragging
//
//  Created by francis gallagher on 6/11/16.
//  Copyright © 2016 Testing. All rights reserved.
//

import UIKit
import Parse
import GoogleSignIn

import FirebaseDatabase

@objc protocol loginDelegate {
    func loggedIn()
}

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    var delegate : loginDelegate?
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    @IBOutlet weak var emailTextLabel: UITextField!
    @IBOutlet weak var passwordTextLabel: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let loginButton = FBSDKLoginButton()
//        loginButton.delegate = self
//        
//        self.view.addSubview(loginButton)
//        loginButton.autoPinEdge(.top, to: .top, of: self.view, withOffset:50)
//        loginButton.autoPinEdge(.left, to: .left, of: self.view, withOffset: 50)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        let registerView = ProfileSetupViewController()
        self.navigationController?.pushViewController(registerView, animated: true)
    }

    @IBAction func loginAction(_ sender: UIButton) {
        PFUser.logInWithUsername(inBackground: emailTextLabel.text!, password: passwordTextLabel.text!, block: {(user, error) -> Void in
            if let error = error as? NSError {
                let errorString = error.userInfo["error"] as? NSString
                print(errorString)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
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
