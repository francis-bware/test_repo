//
//  MessagesViewController.swift
//  Dragging
//
//  Created by francis gallagher on 26/03/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import Parse
import KCFloatingActionButton
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import CoreData
import DateTools

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    var conversationArray = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableview.register(UINib(nibName: "MessageSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        let fab = KCFloatingActionButton()
        fab.addItem("Person", icon: UIImage(named: "avatar")!, handler: { item in
            let teamViewController = PlayerListViewController()
            let navController = UINavigationController(rootViewController: teamViewController)
            navController.navigationBar.barTintColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0)
            self.present(navController, animated: true, completion: nil)
        })
        fab.addItem("Team", icon: UIImage(named: "shield")!, handler: { item in
            let teamViewController = TeamListViewController()
            let navController = UINavigationController(rootViewController: teamViewController)
            navController.navigationBar.barTintColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0)
            self.present(navController, animated: true, completion: nil)
        })
        fab.buttonColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0)
        fab.paddingY = 60
        self.view.addSubview(fab)
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        //        fetchRequest.predicate = NSPredicate(format: "my_role == %@", "manager")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            let teamArray = results as! [Team]
            
            for team in teamArray {
                let conversationRef = Database.database().reference(withPath: "conversation")
                
                conversationRef.queryOrdered(byChild: "team_id").queryEqual(toValue: team.id).observeSingleEvent(of: .value, with: { snapshot in
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext
                    
                    for conversation in snapshot.children {
                        
                        let snapshotValue = snapshot.value as! NSDictionary
                        
                        if let snapshotValue = snapshotValue.allValues.first as? NSDictionary {
                            print(snapshotValue)
                            let last_update = DateFormatters.utcFormat.date(from: snapshotValue["last_update"] as! String)
                            
                            
                            let query = Database.database().reference(withPath: "chat").queryLimited(toLast: 1)
                            _ = query.observe(.childAdded, with: { [weak self] snapshot in
                                
                                if  let data = snapshot.value as? [String: String],
                                    let id = data["sender_id"],
                                    let name = data["name"],
                                    let text = data["text"],
                                    let date = data["date"],
                                    !text.isEmpty {
                                    
                                    let last_update = DateFormatters.utcFormat.date(from: date as! String)
                                    self?.conversationArray.append(["name" : team.name!, "team_id" : snapshotValue["team_id"] as! String, "last_update" : last_update ?? Date(), "last_message" : text])
                                    self?.tableview.reloadData()
                                }
                            })
                        }
                    }
                })
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? MessageSummaryTableViewCell
        
        if cell == nil {
            cell = MessageSummaryTableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            cell?.selectedBackgroundView = backgroundView
        }
        
        let conversation = conversationArray[indexPath.row]
        
        cell?.nameLabel?.text = "\(conversation["name"]!)"
        if let text = conversation["last_message"] as? String{
            cell?.descriptionLabel.text = text
        } else {
            cell?.descriptionLabel.text = "No messages"
        }
            
        if let date = conversation["last_update"] as? NSDate {
            cell?.dateLabel.text = date.shortTimeAgoSinceNow()
        }
        cell?.conversation = conversation
        
//        cell?.restorationIdentifier = conversation.objectId!
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! MessageSummaryTableViewCell
        
        let conversationView = ChatViewController()
        
        conversationView.conversation = cell.conversation
        
        let navController = UINavigationController(rootViewController: conversationView)
        navController.navigationBar.barTintColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0)
        self.present(navController, animated: true, completion: nil)
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
