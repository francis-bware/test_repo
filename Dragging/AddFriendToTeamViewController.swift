//
//  AddFriendToTeamViewController.swift
//  Dragging
//
//  Created by francis gallagher on 26/02/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import Parse
import CoreData

class AddFriendToTeamViewController: UIViewController {
    var delegate : NewPlayerDelegate?

    @IBOutlet weak var tableview: UITableView!
    var friendArray = [PFObject]()
    var team : Team?
    
    var position = 0
    var row = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? AddFriendTableViewCell
        
        if cell == nil {
            cell = AddFriendTableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            cell?.selectedBackgroundView = backgroundView
        }
        
        let friend = friendArray[indexPath.row]
        cell?.textLabel?.text = "\(friend.value(forKey: "first_name")!) \(friend.value(forKey: "last_name")!)"
        cell?.restorationIdentifier = friend.objectId!
        cell?.friend = friend
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! AddFriendTableViewCell
        
        let teamFetch = PFQuery(className: "team")
        let friendObject = cell.friend
        
        teamFetch.whereKey("objectId", equalTo: team!.id!)
        teamFetch.getFirstObjectInBackground{(object, error) -> Void in
            if error == nil {
                if let teamObject = object {
                    let friend = PFObject(withoutDataWithClassName: "person", objectId: cell.restorationIdentifier!)
                    let players = teamObject.relation(forKey: "players")
                    players.add(friend)
                    
                    let friendPlayer = PFObject(className: "team_person")
                    friendPlayer.setValue(0, forKey: "position")
                    friendPlayer.setValue(0, forKey: "row")
                    
                    friendPlayer.saveInBackground { (_, er) in
                        if !(er != nil) {
                            let playerInfo = teamObject.relation(forKey: "player_info")
                            playerInfo.add(friendPlayer)
                            
                            teamObject.saveInBackground { (_, er) in
                                if !(er != nil) {
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    
                                    let managedContext = appDelegate.managedObjectContext
                                    
                                    let entity =  NSEntityDescription.entity(forEntityName: "Player", in:managedContext)
                                    
                                    let id = Int(arc4random_uniform(100000) + 1) as NSNumber
                                    
                                    let player = Player(entity: entity!, insertInto: managedContext)
                                    
                                    player.first_name = friendObject?.value(forKey: "first_name") as? String
                                    player.last_name = friendObject?.value(forKey: "last_name") as? String
                                    player.position = self.position as NSNumber?
                                    player.row = self.row as NSNumber?
                                    player.id = friendObject?.objectId
                                    
                                    
                                    self.team?.addToPlayers(player)
                                    
                                    do {
                                        try managedContext.save()
                                        
                                        self.delegate?.addedNewPlayer(player)
                                        self.dismiss(animated: true, completion: nil)
                                    } catch let error as NSError  {
                                        print("Could not save \(error), \(error.userInfo)")
                                    }
                                    
                                } else {
                                    // Something went wrong
                                }
                            }
                        } else {
                            // Something went wrong
                        }
                    }
                    
                    
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
