//
//  PlayerListViewController.swift
//  Dragging
//
//  Created by francis gallagher on 26/03/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import CoreData
import Parse

class PlayerListViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    var teamArray = [Team]()
    var friendArray = [PFObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.register(UINib(nibName: "CreateMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")

        // Do any additional setup after loading the view.
        
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.backAction))
        navigationItem.leftBarButtonItem = backButton
        
        self.title = "Player Message"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let person = PFUser.current()?.object(forKey: "person") as? PFObject {
            let managerQuery = PFQuery(className: "person")
            managerQuery.whereKey("friends", equalTo: person)
            
            managerQuery.findObjectsInBackground{
                (objects, error) -> Void in
                
                if error == nil {
                    self.friendArray = objects!
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
                    
                    fetchRequest.predicate = NSPredicate(format: "players.@count != 0")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                    
                    do {
                        let results = try managedContext.fetch(fetchRequest)
                        
                        self.teamArray = results as! [Team]
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                    }
                    
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        var count = teamArray.count
        
        if friendArray.count > 0 {
            count += 1
        }
        
        return count
    }
    
    func tableView(_ tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        if friendArray.count > 0 && section == 0 {
            return "Friends"
        }
        
        var count = section
        
        if friendArray.count > 0 {
            count -= 1
        }
        
        let team = teamArray[count]
        
        return team.name!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendArray.count > 0 && section == 0 {
            return friendArray.count
        }
        
        var count = section
        
        if friendArray.count > 0 {
            count -= 1
        }
        
        let team = teamArray[count]
        
        return (team.players?.allObjects.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CreateMessageTableViewCell
        
        if cell == nil {
            cell = CreateMessageTableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            cell?.selectedBackgroundView = backgroundView
        }
        
        if friendArray.count > 0 && indexPath.section == 0 {
            let friend = friendArray[indexPath.row]
            cell?.nameLabel?.text = "\(friend.value(forKey: "first_name")!) \(friend.value(forKey: "last_name")!)"
            cell?.restorationIdentifier = friend.objectId!
            cell?.profileImage?.image = UIImage(named: "20801.png")
            
            cell?.object = friend
        } else {
            var count = indexPath.section
            
            if friendArray.count > 0 {
                count -= 1
            }
            
            let team = teamArray[count]
            let player = team.players?.allObjects[indexPath.row] as! Player
            cell?.nameLabel?.text = "\(player.first_name!) \(player.last_name!)"
            cell?.restorationIdentifier = team.id!
            
            if let imageString = player.photo {
                cell?.profileImage?.hnk_setImageFromURL(NSURL(string: imageString)! as URL)
            } else {
                cell?.profileImage?.image = UIImage(named: "20801.png")
            }
            
            cell?.object = PFObject(withoutDataWithClassName: "Person", objectId: "\(player.id!)")
        }
        
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CreateMessageTableViewCell
        
        let conversation = PFObject(className: "Conversation")
        
        let people = conversation.relation(forKey: "people")
        
        people.add(cell.object!)
        
        if let person = PFUser.current()?.object(forKey: "person") as? PFObject {
            
            people.add(person)
            
            conversation.saveInBackground { (_, er) in
                if !(er != nil) {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    // Something went wrong
                }
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
