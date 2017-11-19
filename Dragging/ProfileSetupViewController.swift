//
//  ProfileSetupViewController.swift
//  Dragging
//
//  Created by francis gallagher on 5/03/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import CoreData
import Parse

class ProfileSetupViewController: UIViewController {
    
    @IBOutlet weak var firstNameLabel: UITextField!

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var PasswordLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var mobileLabel: UITextField!
    @IBOutlet weak var sexLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profileImage.layer.cornerRadius = 50
        profileImage.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhotoAction(_ sender: UIButton) {
        
        let registerView = TakePhotoViewController()
        self.navigationController?.pushViewController(registerView, animated: true)
        
        let user = PFUser()
        user.username = emailLabel.text
        user.email = emailLabel.text
        user.password = PasswordLabel.text
        
        let person = PFObject(className: "person")
        person.setValue(firstNameLabel.text, forKey: "first_name")
        person.setValue(lastNameLabel.text, forKey: "last_name")
        person.setValue(emailLabel.text, forKey: "email")
        person.setValue(sexLabel.text, forKey: "gender")
        person.setValue(mobileLabel.text, forKey: "phone_number")
        
        registerView.user = user
        registerView.person = person
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
