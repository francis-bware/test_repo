//
//  TeamSummaryViewController.swift
//  Dragging
//
//  Created by francis gallagher on 30/12/16.
//  Copyright © 2016 Testing. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import Parse
import KCFloatingActionButton
import FirebaseCore
import FirebaseDatabase
import CoreData
import FirebaseInvites
import GoogleSignIn
import FirebaseAuth

class TeamSummaryViewController: UIViewController, OBOvumSource, OBDropZone, PlayerFormationDelegate, FBSDKAppInviteDialogDelegate, NewPlayerDelegate, InviteDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var gameInfo = [String : String]()
    var gameInfoKeys = [String]()
    
    var manager = false
    @IBOutlet weak var formationView: PlayerFormationView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var matchId = ""
    var matchStartDate : Date?
    var matchEndDate : Date?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var groundNameLabel: UILabel!
    @IBOutlet weak var awayNameLabel: UILabel!
    @IBOutlet weak var homeNameLabel: UILabel!
    @IBOutlet weak var awayLogoImage: UIImageView!
    @IBOutlet weak var homeLogoImage: UIImageView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    let fab = KCFloatingActionButton()
    
    @IBOutlet weak var vsBackgroundview: UIImageView!
    var draggingView : PlayerDragView?
    
    var team : Team?
    
    @IBOutlet weak var backgroundView: UIImageView!
    
    var myPlayer : Player?
    var viewingPlayer : Player?
    var addingPlayerView : PlayerDragView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        homeLogoImage.layer.cornerRadius = 20
        awayLogoImage.layer.cornerRadius = 20
        groundNameLabel.layer.cornerRadius = 5
        awayNameLabel.layer.cornerRadius = 5
        homeNameLabel.layer.cornerRadius = 5
        vsBackgroundview.layer.cornerRadius = 5
        formationView.layer.cornerRadius = 5
        groundNameLabel.clipsToBounds = true
        awayNameLabel.clipsToBounds = true
        homeNameLabel.clipsToBounds = true
        
        homeNameLabel.text = team?.name
        titleLabel.text = team?.name
        
        let fileName = "\(team!.id!).png"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + fileName
        if let image = UIImage(contentsOfFile: path) {
            homeLogoImage.image = image
        } else {
            homeLogoImage.image = UIImage(named: "shield.png")
        }
        
        formationView.team = self.team
        formationView.parentController = self
        formationView.delegate = self
        print(team)
        formationView.populatePlayers(sport: "Soccer", players: team?.players?.allObjects as! [Player], formation:  self.team?.formation as! [Int])
        
        let amount = 30
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        backgroundView.addMotionEffect(group)
        
        scrollView.contentSize = CGSize(width: 0, height: 1750)
        
        
        
        self.setFloatingActions()
//        fab.addItem("Team", icon: UIImage(named: "shield")!, handler: { item in
//            let teamViewController = TeamListViewController()
//            let navController = UINavigationController(rootViewController: teamViewController)
//            navController.navigationBar.barTintColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0)
//            self.present(navController, animated: true, completion: nil)
//        })
        fab.buttonColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0)
        fab.paddingY = 22
        self.view.addSubview(fab)
        
        self.tableView.layer.cornerRadius = 5
        
        let matchRef = Database.database().reference(withPath: "match")
        
        matchRef.queryOrdered(byChild: "status").queryEqual(toValue: "active").observe(.value, with: { snapshot in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
            let managedContext = appDelegate.managedObjectContext
            
            if let snapshotValue = snapshot.value as? NSDictionary {
                print(snapshot.children.allObjects)
                if let snapshotValue = snapshotValue.allValues.first as? NSDictionary {
                    
                    if let matchDict = snapshot.children.allObjects.first as? DataSnapshot {
                        print(matchDict)
                        self.matchId = matchDict.key
                    }
                    self.awayNameLabel.text = snapshotValue["awayTeam"] as? String
                    self.homeNameLabel.text = self.team?.name
                    self.groundNameLabel.text = snapshotValue["ground"] as? String
                    
                    if let dateString = snapshotValue["date"] as? String {
                        let date = DateFormatters.utcFormat.date(from: dateString)
                        
                        self.dateLabel.text = DateFormatters.dateOnlyFormat.string(from: date!)
                        self.timeLabel.text = DateFormatters.timeOnlyFormat.string(from: date!)
                    }
                    if let dateString = snapshotValue["endDate"] as? String {
                        self.matchEndDate = DateFormatters.utcFormat.date(from: dateString)
                    }
                    
                    if let homeLogo = snapshotValue["homePhoto"] as? String {
                        self.homeLogoImage.hnk_setImageFromURL(URL(string:homeLogo)!)
                    }
                    
                    if let awayLogo = snapshotValue["awayPhoto"] as? String {
                        self.awayLogoImage.hnk_setImageFromURL(URL(string:awayLogo)!)
                    }
                    
                    if let status = snapshotValue["status"] as? String {
                        if status == "Cancelled" {
                            self.dateLabel.text = ""
                            self.timeLabel.text = ""
                            self.groundNameLabel.text = "Cancelled"
                            self.groundNameLabel.font = UIFont.systemFont(ofSize: 16)
                            self.groundNameLabel.backgroundColor = UIColor.red
                        } else {
                            self.groundNameLabel.backgroundColor = UIColor.darkGray
                            self.groundNameLabel.font = UIFont.systemFont(ofSize: 14)
                        }
                    }
                    
                    print(self.team!.id!)
                    if let fixture = snapshotValue[self.team!.id!] as? String {
                        print(fixture)
                        let teamFixtureRef = Database.database().reference(withPath: "teamFixture")
                        teamFixtureRef.queryOrdered(byChild: fixture).observe(.value, with: { snapshot in
                            
                            let snapshotValue = snapshot.value as! NSDictionary
                            
                            if let snapshotValue = snapshotValue.allValues.first as? NSDictionary {
                                
                                if let formation = snapshotValue["formation"] as? NSArray {
                                    print(formation)
                                    self.team?.formation = formation as? [NSNumber]
                                    do {
                                        try managedContext.save()
                                        
                                        self.formationView.populatePlayers(sport: "Soccer", players: self.team?.players?.allObjects as! [Player], formation:  self.team?.formation as! [Int])
                                        
                                        self .checkMatchDate()
                                    } catch let error as NSError  {
                                        print("Could not save \(error), \(error.userInfo)")
                                    }
                                    
                                }
                                
                                if let gameInfo = snapshotValue["gameInfo"] as? [String : String] {
                                    self.gameInfo = gameInfo
                                    self.gameInfoKeys = Array(gameInfo.keys)
                                    self.tableView.reloadData()
                                }
                            }
                        })
                    }
                    
                }
            }
                
            
            
            
        })
        
        let playerRef = Database.database().reference(withPath: "player")
        print(self.team!.id!)
        playerRef.queryOrdered(byChild: self.team!.id!).queryEqual(toValue: 1).observe(.value, with: { snapshot in
            if let snapshotValue = snapshot.value as? NSDictionary {
                print(snapshotValue.allValues)
                var count = 0
                for value in snapshotValue.allValues {
                    if let snapshotValue = value as? NSDictionary {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        
                        let managedContext = appDelegate.managedObjectContext
                        
                        let entity =  NSEntityDescription.entity(forEntityName: "Player", in:managedContext)
                        
                        let id = (snapshot.value as! NSDictionary).allKeys[count] as! String
                        print(id)
                        count += 1
                        
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
                        
                        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                        
                        do {
                            let results = try managedContext.fetch(fetchRequest)
                            
                            if  results.count > 0 {
                                if let playerObject = results[0] as? Player {
                                    playerObject.first_name = snapshotValue.value(forKey: "first_name") as? String
                                    playerObject.last_name = snapshotValue.value(forKey: "last_name") as? String
                                    
                                    playerObject.availability = snapshotValue.value(forKey: "availability") as? String
                                    playerObject.finance = snapshotValue.value(forKey: "finance") as? String
                                    playerObject.photo = snapshotValue.value(forKey: "photo") as? String
                                    playerObject.email = snapshotValue.value(forKey: "email") as? String
                                    playerObject.phone = snapshotValue.value(forKey: "phone") as? String
                                    
                                    if let position = snapshotValue.value(forKey: "position") as? NSArray {
                                        playerObject.position = position[1] as! NSNumber
                                        playerObject.row = position[0] as! NSNumber
                                    }
                                    if let userImageFile = snapshotValue["photo"] as? PFFile {
                                        playerObject.photo = userImageFile.url
                                    }
                                    
                                    if let userId = snapshotValue.value(forKey: "userUid") as? String {
                                        if userId == Auth.auth().currentUser!.uid {
                                            self.myPlayer = playerObject
                                        }
                                    }
                                    
                                    print(playerObject)
                                }
                            } else {
                                let playerObject = Player(entity: entity!, insertInto: managedContext)
                                
                                playerObject.id = id
                                
                                playerObject.first_name = snapshotValue.value(forKey: "first_name") as? String
                                playerObject.last_name = snapshotValue.value(forKey: "last_name") as? String
                                
                                playerObject.availability = snapshotValue.value(forKey: "availability") as? String
                                playerObject.finance = snapshotValue.value(forKey: "finance") as? String
                                playerObject.photo = snapshotValue.value(forKey: "photo") as? String
                                playerObject.email = snapshotValue.value(forKey: "email") as? String
                                playerObject.phone = snapshotValue.value(forKey: "phone") as? String
                                
                                if let position = snapshotValue.value(forKey: "position") as? NSArray {
                                    playerObject.position = position[1] as! NSNumber
                                    playerObject.row = position[0] as! NSNumber
                                }
                                if let userImageFile = snapshotValue["photo"] as? PFFile {
                                    playerObject.photo = userImageFile.url
                                }
                                
                                if let userId = snapshotValue.value(forKey: "userUid") as? String {
                                    if userId == Auth.auth().currentUser!.uid {
                                        self.myPlayer = playerObject
                                    }
                                }
                                
                                self.team?.addToPlayers(playerObject)
                            }
                            
                            try managedContext.save()
                            
                            self.formationView.populatePlayers(sport: "Soccer", players: self.team?.players?.allObjects as! [Player], formation:  self.team?.formation as! [Int])
                            self.setFloatingActions()
                            
                        } catch let error as NSError {
                            print("Could not fetch \(error), \(error.userInfo)")
                        }
                    }
                }
            }
            
            
            
        })
//
        if let invite = Invites.inviteDialog() {
            invite.setInviteDelegate(self)

            // NOTE: You must have the App Store ID set in your developer console project
            // in order for invitations to successfully be sent.

            // A message hint for the dialog. Note this manifests differently depending on the
            // received invitation type. For example, in an email invite this appears as the subject.

            invite.setMessage("Try this out!")
            // Title for the dialog, this is what the user sees before sending the invites.
            invite.setTitle("Invites Example")
            invite.setDeepLink("https://p3zhc.app.goo.gl/6SuK")
            invite.setCallToActionText("Install!")
//            invite.setCustomImage("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")
//            invite.open()
        }
        
        
    }
    
    func updateAvailability(_ availability : String) {
        let playerRef = Database.database().reference(withPath: "player")
        
        playerRef.child(self.myPlayer!.id!).updateChildValues(["availability" : availability] as Dictionary)
    }
    
    func setFloatingActions() {
        for item in self.fab.items {
            self.fab.removeItem(item: item)
        }
        if self.myPlayer != nil {
            fab.addItem("Set Availability", icon: UIImage(named: "avatar")!, handler: { item in
                let alertController: UIAlertController = UIAlertController(title: "Update Your Current Availability Status", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                let availablePlayerAction: UIAlertAction = UIAlertAction(title: "Available", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) -> () in
                    self.updateAvailability("available")
                })
                let unavailablePlayerAction: UIAlertAction = UIAlertAction(title: "Unavailable", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) -> () in
                    self.updateAvailability("unavailable")
                })
                alertController.addAction(cancelAction)
                alertController.addAction(availablePlayerAction)
                alertController.addAction(unavailablePlayerAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
        }
        
        if team!.owner {
            fab.addItem("Add player", icon: UIImage(named: "avatar")!, handler: { item in
                self.performSegue(withIdentifier: "showAddPlayerFromTeamFormationView", sender: self)
            })
            fab.addItem("Network", icon: UIImage(named: "avatar")!, handler: { item in
                self.performSegue(withIdentifier: "showAddFriendToTeam", sender: self)
            })
        }
    }
    
    func checkMatchDate() {
        if matchEndDate != nil {
            if matchEndDate! < Date() {
                let alert = UIAlertController(title: "Match Has Finished", message: "This match has been completed. Would you like to add your next fixture?", preferredStyle: UIAlertControllerStyle.alert)
                
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.viewMatchupAction))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self .checkMatchDate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: (UIStoryboardSegue!), sender: Any!) {
        if (segue.identifier == "showAddPlayerFromTeamFormationView") {
            let nav = segue.destination as! UINavigationController
            let playerViewController : NewPlayerViewController = nav.topViewController as! NewPlayerViewController
            
            playerViewController.team = team
            playerViewController.delegate = self
            if let view = addingPlayerView {
                playerViewController.position = view.position!
                playerViewController.row = view.row!
            }
        } else if (segue.identifier == "showStudentProfileFromTeam") {
            let nav = segue.destination as! UINavigationController
            let playerViewController : PlayerProfileViewController = nav.topViewController as! PlayerProfileViewController
            
            playerViewController.player = viewingPlayer
        } else if (segue.identifier == "showAddFriendToTeam") {
            let nav = segue.destination as! UINavigationController
            let playerViewController : AddFriendToTeamViewController = nav.topViewController as! AddFriendToTeamViewController
            
            playerViewController.team = team
            playerViewController.delegate = self
            if let view = addingPlayerView {
                playerViewController.position = view.position!
                playerViewController.row = view.row!
            }
        }
    }
    
    func createOvum(from sourceView: UIView!) -> OBOvum! {
        let ovum = OBOvum()
        ovum.dataObject = sourceView.tag as NSNumber
        return ovum
    }
    
    func createDragRepresentation(ofSourceView sourceView: UIView!, in window: UIWindow!) -> UIView! {
        
        draggingView = sourceView as? PlayerDragView
        
        var frame = sourceView.convert(sourceView.bounds, to: sourceView.window)
        frame  = window.convert(frame, to: sourceView.window)
        frame.size.height = 60
        frame.size.width = 60
        frame.origin.y -= 25
        
        let dragImage = UIImageView(frame: frame)
        dragImage.image = draggingView?.imageView?.image
        dragImage.layer.cornerRadius = 30
        dragImage.clipsToBounds = true
        dragImage.contentMode = UIViewContentMode.scaleAspectFill
        
        dragImage.layer.borderWidth = 1
        dragImage.layer.borderColor = UIColor(red: CGFloat(48/255.0), green: CGFloat(218/255.0), blue: CGFloat(224/255.0), alpha: 1.0).cgColor
        
        return dragImage
    }
    
    func ovumEntered(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) -> OBDropAction {
//        if let stackView = view as? UIStackView {
//            draggingView?.player?.row = 1
//            draggingView?.player?.position = 2
//            formationView.populatePlayers(sport: "Soccer", players: team?.players?.allObjects as! [Player], formation:  [2, 2, 2, 4, 1])
//        }
        return OBDropAction.copy
    }
    
    func ovumExited(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) {
//        view.backgroundColor = UIColor.white
    }
    
    func ovumDropped(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) {
        
        print(draggingView?.player)
        
        if let playerView = view as? PlayerDragView {
            let initialRow = draggingView?.player?.row
            let initialPosition = draggingView?.player?.position
            
            var playerArray = [PFObject]()
            
            let playerRef = Database.database().reference(withPath: "player")
            
            
            if draggingView?.player != nil {
                let draggingPlayer = PFObject(withoutDataWithClassName: "team_person", objectId: "\(draggingView!.player!.id!)")
                print("\(playerView.row!)")
                print("\(playerView.position!)")
                draggingPlayer["row"] = playerView.row!
                draggingPlayer["position"] = playerView.position!
                playerArray.append(draggingPlayer)
            }
            
            if playerView.player != nil {
                let replacedPlayer = PFObject(withoutDataWithClassName: "team_person", objectId: "\(playerView.player!.id!)")
                print("\(playerView.player!.id)")
                replacedPlayer["row"] = initialRow
                replacedPlayer["position"] = initialPosition
                playerArray.append(replacedPlayer)
                
                playerRef.child(playerView.player!.id!).updateChildValues(["position" : [initialRow, initialPosition]] as Dictionary)
            }
            
            playerRef.child(draggingView!.player!.id!).updateChildValues(["position" : [NSNumber(value: playerView.row!), NSNumber(value: playerView.position!)]] as Dictionary)
            
            self.draggingView?.player?.row = playerView.row as NSNumber?
            self.draggingView?.player?.position = playerView.position as NSNumber?
            playerView.player?.row = initialRow
            playerView.player?.position = initialPosition
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            view.backgroundColor = UIColor.white
            
            self.formationView.populatePlayers(sport: "Soccer", players: self.team?.players?.allObjects as! [Player], formation:  self.team?.formation as! [Int])
        
            
            self.draggingView?.player?.row = playerView.row as NSNumber?
            self.draggingView?.player?.position = playerView.position as NSNumber?
            playerView.player?.row = initialRow
            playerView.player?.position = initialPosition
            
            
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            view.backgroundColor = UIColor.white
            
            self.formationView.populatePlayers(sport: "Soccer", players: self.team?.players?.allObjects as! [Player], formation:  self.team?.formation as! [Int])
            
        } else if let dropView = view as? UIScrollView {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            if draggingView?.player != nil {
                let draggingPlayer = PFObject(withoutDataWithClassName: "team_person", objectId: "\(draggingView!.player!.id!)")
                
                draggingPlayer["row"] = 0
                draggingPlayer["position"] = 0
                
                draggingPlayer.saveInBackground(block: { (_, er) in
                    if !(er != nil) {
                        self.draggingView?.player?.row = 0
                        self.draggingView?.player?.position = 0
                        
                        do {
                            try managedContext.save()
                            
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                    }
                    
                    self.formationView.populatePlayers(sport: "Soccer", players: self.team?.players?.allObjects as! [Player], formation:  self.team?.formation as! [Int])
                })
            }
            
            
            self.draggingView?.player?.row = 0
            self.draggingView?.player?.position = 0
            
            do {
                try managedContext.save()
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        
        
            self.formationView.populatePlayers(sport: "Soccer", players: self.team?.players?.allObjects as! [Player], formation:  self.team?.formation as! [Int])
        
        }
    
    }

    func addNewPlayer(_ view : PlayerDragView?) {
        
        
//        let content = FBSDKAppInviteContent()
//        content.appLinkURL = NSURL(string: "https://fb.me/1812416732365498") as URL!
//
//        FBSDKAppInviteDialog.show(from: self, with: content, delegate: self)
        
        addingPlayerView = view
        
        let alertController: UIAlertController = UIAlertController(title: "Select an action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let addFriendAction: UIAlertAction = UIAlertAction(title: "Select From Friends", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) -> () in
            self.performSegue(withIdentifier: "showAddFriendToTeam", sender: self)
        })
        let newPlayerAction: UIAlertAction = UIAlertAction(title: "Add New Player", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) -> () in
            self.performSegue(withIdentifier: "showAddPlayerFromTeamFormationView", sender: self)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(addFriendAction)
        alertController.addAction(newPlayerAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addedNewPlayer(_ player : Player?){
        formationView.populatePlayers(sport: "Soccer", players: team?.players?.allObjects as! [Player], formation:  self.team?.formation as! [Int])
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print(results)
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print(error)
    }
    
    func viewPlayerProfile(_ player : Player?){
        if player != nil {
            viewingPlayer = player
            self.performSegue(withIdentifier: "showStudentProfileFromTeam", sender: self)
        }
    }
    
    @IBAction func viewMatchupAction(_ sender: AnyObject) {
        let mathcupViewController = EditMatchupViewController()
        mathcupViewController.team = self.team
        mathcupViewController.oldMatchId = self.matchId
        let navController = UINavigationController(rootViewController: mathcupViewController)
        navController.navigationBar.barTintColor = UIColor(red: CGFloat(41/255.0), green: CGFloat(192/255.0), blue: CGFloat(197/255.0), alpha: 1.0)
        self.present(navController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        if (indexPath.row > 0) && (indexPath.row < self.gameInfo.count + 1) {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            
            let alert = UIAlertController(title: "Remove Field", message: "Are you sure you want to remove this field?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: removeInfo))
            
            self.present(alert, animated: true, completion: nil)
            
        default:
            return
        }
    }
    
    func removeInfo(_ alert: UIAlertAction!) {
        
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        self.tableViewHeight.constant = CGFloat(44*(self.gameInfo.count + 2))
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameInfo.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
            
            cell?.textLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
            cell?.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        }
        
        if indexPath.row == 0 {
            cell?.textLabel?.text = "Team Manager"
            cell?.detailTextLabel?.text = "Justin Eiman"
        } else if indexPath.row < (self.gameInfo.count + 1) {
            let index = gameInfoKeys[indexPath.row - 1]
            cell?.textLabel?.text = index
            cell?.detailTextLabel?.text = gameInfo[index]
        } else {
            cell?.textLabel?.text = "Add a new entry"
            cell?.detailTextLabel?.text = ""
        }
        cell?.textLabel?.textColor = UIColor.gray
        cell?.detailTextLabel?.textColor = UIColor.lightGray
        cell?.accessoryType = .none
    
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell!.selectedBackgroundView = backgroundView
        
        cell?.layoutMargins = UIEdgeInsets.zero
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.gameInfo.count + 1 {
            let gameInfoViewController = EditGameInfoViewController()
            let navController = UINavigationController(rootViewController: gameInfoViewController)
            navController.navigationBar.barTintColor = UIColor(red: CGFloat(41/255.0), green: CGFloat(192/255.0), blue: CGFloat(197/255.0), alpha: 1.0)
            self.present(navController, animated: true, completion: nil)
        }
    }
}
