//
//  PlayerProfileViewController.swift
//  Dragging
//
//  Created by francis gallagher on 29/01/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class PlayerProfileViewController: UIViewController {
    var player : Player?
    var team : Team?
    
    @IBOutlet weak var availabilityTextField: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sportProfileContainer: UIView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    var playerAttributeArray = [String]()
    var playerAttributeDict = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profilePicView.layer.cornerRadius = 50
        profilePicView.layer.borderWidth = 3
        profilePicView.clipsToBounds = true
        profilePicView.layer.borderColor = UIColor(red: CGFloat(48/255.0), green: CGFloat(218/255.0), blue: CGFloat(224/255.0), alpha: 1.0).cgColor
        sportProfileContainer.layer.cornerRadius = 5
        sportProfileContainer.clipsToBounds = true
        
        nameLabel.text = (player?.first_name)! + " " + (player?.last_name)!
        
        self.title = "Player Profile"
        
        if let email = self.player!.email {
            playerAttributeArray.append("Email")
            playerAttributeDict["Email"] = email
        }
        if let phone = self.player!.phone {
            playerAttributeArray.append("Mobile Number")
            playerAttributeDict["Mobile Number"] = phone
        }
        
        if player?.availability == "Available" {
            self.availabilityTextField.text = "Available"
        } else if player?.availability == "Unavailable" {
            self.availabilityTextField.text = "Unavailable"
        } else {
            self.availabilityTextField.text = "Availability Unknown"
        }
        
        tableHeightConstraint.constant = (44 * CGFloat(playerAttributeArray.count))

        if let imageString = player?.photo {
            profilePicView.hnk_setImageFromURL(NSURL(string: imageString)! as URL)
        }
        
        let deleteButton = UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(self.deleteAction))
        deleteButton.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItems = [deleteButton]
    }
    
    func deleteAction() {
        let alert = UIAlertController(title: "Remove Player", message: "Are you sure you want to remove this player from this team?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: deleteConfirmed))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteConfirmed(_ alert: UIAlertAction!) {
        let ref = Database.database().reference(withPath: "player").child(self.player!.id!)
        
        ref.removeValue()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.contentSize = CGSize(width: 0, height: sportProfileContainer.frame.origin.y + sportProfileContainer.frame.size.height + 100)
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
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerAttributeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            cell!.selectedBackgroundView = backgroundView
        }
        
        let attribute = playerAttributeArray[indexPath.row]
        cell?.textLabel?.text = attribute
        
        if let value = playerAttributeDict[attribute] {
            cell?.detailTextLabel?.text = value
        } else {
            cell?.detailTextLabel?.text = ""
        }
        
        return cell!
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
