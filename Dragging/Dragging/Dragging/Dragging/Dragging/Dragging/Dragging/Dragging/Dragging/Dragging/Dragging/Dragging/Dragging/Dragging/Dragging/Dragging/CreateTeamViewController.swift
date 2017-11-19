//
//  CreateTeamViewController.swift
//  Dragging
//
//  Created by francis gallagher on 30/12/16.
//  Copyright © 2016 Testing. All rights reserved.
//

import UIKit
import CoreData

class CreateTeamViewController: UIViewController {
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var sportTextField: HoshiTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func saveAction(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        let teamEntity =  NSEntityDescription.entity(forEntityName: "Team", in:managedContext)
        
        let team = Team(entity: teamEntity!, insertInto: managedContext)
        
        team.name = nameTextField.text
        team.sport = sportTextField.text
        do {
            try managedContext.save()
            
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
