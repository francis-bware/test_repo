//
//  TeamListViewController.swift
//  Dragging
//
//  Created by francis gallagher on 26/03/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import CoreData
import Parse

class TeamListViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    var teamArray = [Team]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.register(UINib(nibName: "CreateMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "my_role == %@", "manager")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            teamArray = results as! [Team]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.backAction))
        navigationItem.leftBarButtonItem = backButton
        
        self.title = "Team Message"
    }
    
    func backAction() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CreateMessageTableViewCell
        
        if cell == nil {
            cell = CreateMessageTableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            cell?.selectedBackgroundView = backgroundView
        }
        
        let team = teamArray[indexPath.row]
        cell?.nameLabel?.text = "\(team.name!)"
        cell?.restorationIdentifier = team.id!
        
        let fileName = "\(team.id!).png"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + fileName
        if let image = UIImage(contentsOfFile: path) {
            cell?.profileImage?.image = image
        } else {
            cell?.profileImage?.image = UIImage(named: "shield.png")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        
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
