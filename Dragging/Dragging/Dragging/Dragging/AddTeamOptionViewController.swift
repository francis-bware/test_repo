//
//  AddTeamOptionViewController.swift
//  Dragging
//
//  Created by francis gallagher on 15/12/16.
//  Copyright © 2016 Testing. All rights reserved.
//

import UIKit

class AddTeamOptionViewController: UIViewController {
    @IBOutlet weak var createTeamButton: UIButton!

    @IBOutlet weak var joinTeamButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
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
    @IBAction func createTeamAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showCreateTeam", sender: self)
    }

}
