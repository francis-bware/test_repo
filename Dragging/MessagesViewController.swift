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

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    var conversationArray = [PFObject]()
    
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
        
        if let person = PFUser.current()?.object(forKey: "person") as? PFObject {
            let conversationQuery = PFQuery(className: "Conversation")
            conversationQuery.whereKey("people", equalTo: person)
            
            conversationQuery.findObjectsInBackground{
                (objects, error) -> Void in
                
                if error == nil {
                    self.conversationArray = objects!
                    
                    self.tableview.reloadData()
                }
            }
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
        
        if let people = conversation.value(forKey: "people") as? PFRelation {
            let peopleArray = people.query()
            print(peopleArray)
        }
        
        cell?.nameLabel?.text = "\(conversation.value(forKey: "name")!)"
        cell?.descriptionLabel.text = "No messages"
        cell?.conversation = conversation
        
        cell?.restorationIdentifier = conversation.objectId!
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! MessageSummaryTableViewCell
        
        let conversationView = ConversationViewController(tableViewStyle: .plain)
        
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
