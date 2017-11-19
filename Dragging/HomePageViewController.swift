//
//  HomePageViewController.swift
//  Dragging
//
//  Created by francis gallagher on 13/12/16.
//  Copyright © 2016 Testing. All rights reserved.
//

import UIKit
import CoreData
import Parse
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class HomePageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var teamIds = [String]()
    var ref: DatabaseReference!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "", image: UIImage(named: "referee"), tag: 5)
        tabBarItem.selectedImage = UIImage(named: "referee_active")
    }

    var myViewControllers = [UIViewController]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentUser = PFUser.current()
        
        if Auth.auth().currentUser == nil {
        //if currentUser == nil {
            let loginViewController = LoginViewController()
            let navController = UINavigationController(rootViewController: loginViewController)
            navController.navigationBar.barTintColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0)
            self.present(navController, animated: true, completion: nil)
        } else {
            let teamRef = Database.database().reference(withPath: "team")
            
            teamRef.queryOrdered(byChild: Auth.auth().currentUser!.uid).queryEqual(toValue: 1).observeSingleEvent(of: .value, with: { snapshot in
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                let managedContext = appDelegate.managedObjectContext
                
                for team in snapshot.children {
                    print(snapshot.value)
                    
                    if !self.teamIds.contains((team as! DataSnapshot).key) {
                        let snapshotValue = snapshot.value as! NSDictionary
                        
                        if let snapshotValue = snapshotValue.allValues.first as? NSDictionary {
                            
                            let teamEntity =  NSEntityDescription.entity(forEntityName: "Team", in:managedContext)
                            
                            let teamObject = Team(entity: teamEntity!, insertInto: managedContext)
                            
                            teamObject.name = snapshotValue["name"] as! String?
                            teamObject.formation = snapshotValue.value(forKey: "formation") as? [NSNumber]
                            teamObject.id = (team as! DataSnapshot).key
                            teamObject.my_role = "manager"
                            
                            if let managers = snapshotValue["manager"] as? [String] {
                                if managers.contains(Auth.auth().currentUser!.uid) {
                                    teamObject.owner = true
                                }
                            }
                            
                            teamObject.players = []
                            
                            do {
                                try managedContext.save()
                                
                                self.dismiss(animated: true, completion: nil)
                            } catch let error as NSError  {
                                print("Could not save \(error), \(error.userInfo)")
                            }
                            self.addTeamController(teamObject)
                        }
                    }
                }
                
                
            })
            
        }
        
        
        
//        self.ref.child("player").childByAutoId().setValue(["first_name" : "Francis", "last_name" : "Gallagher", ] as Dictionary)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let myView = view?.subviews.first as? UIScrollView {
            myView.canCancelContentTouches = false
        }
        
        self.delegate = self
        self.dataSource = self
        
        self.setupTeamControllers()
        
        self.loadTeams()
        ref = Database.database().reference()
    }
    
    func loggedIn() {
        self.setupTeamControllers()
    }
    
    func addTeamController(_ team : Team) {
        let teamView = self.storyboard?.instantiateViewController(withIdentifier: "teamView") as! TeamSummaryViewController
        teamView.team = team
        
        myViewControllers.insert(teamView, at: self.teamIds.count)
        if self.teamIds.count == 0 {
            self.setViewControllers([myViewControllers[0]], direction: .forward, animated: true, completion: nil)
        }
        self.teamIds.append(team.id!)
    }
    
    func setupTeamControllers() {
        myViewControllers = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            for result in results as! [Team] {
                let teamView = self.storyboard?.instantiateViewController(withIdentifier: "teamView") as! TeamSummaryViewController
                teamView.team = result
                myViewControllers.append(teamView)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let red = self.storyboard?.instantiateViewController(withIdentifier: "RedID")
        myViewControllers.append(red!)
        
        self.setViewControllers([myViewControllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func loadTeams() {
        
        do {
            try PFUser.current()?.fetch()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        if let person = PFUser.current()?.object(forKey: "person") as? PFObject {
            person.fetchInBackground(block: {(object, error) -> Void in
                if let userImageFile = object?["photo"] as? PFFile {
                    print(userImageFile.url)
                    
                    person.setObject(userImageFile.url!, forKey: "photoUrl")
                }
            })
            
            let managerQuery = PFQuery(className: "team")
            managerQuery.whereKey("managers", equalTo: person)
            managerQuery.includeKey("players")
            
            managerQuery.findObjectsInBackground{
                (objects, error) -> Void in
                
                if error == nil {
                    print(objects)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext
                    let teamEntity =  NSEntityDescription.entity(forEntityName: "Team", in:managedContext)
                    
                    for object in objects! {
                        let teamObject = Team(entity: teamEntity!, insertInto: managedContext)
                        
                        teamObject.name = object.value(forKey: "name") as! String?
                        teamObject.formation = object.value(forKey: "formation") as? [NSNumber]
                        teamObject.id = object.objectId
                        teamObject.my_role = "manager"
                        
                        //                    if let image = self.teamImage {
                        //                        if let data = UIImagePNGRepresentation(image) {
                        //                            let filename = self.getDocumentsDirectory().appendingPathComponent("\(team.objectId).png")
                        //                            try? data.write(to: filename)
                        //                        }
                        //                    }
                        
                        let players = object.value(forKey: "player_info") as! PFRelation
                        
                        let playerQuery = players.query()
                        
                        do {
                            let playerObjects = try playerQuery.findObjects()
                            
                            for player in playerObjects {
                                let entity =  NSEntityDescription.entity(forEntityName: "Player", in:managedContext)
                                
                                let playerObject = Player(entity: entity!, insertInto: managedContext)
                                
                                
                                do {
                                    
                                    let entity =  NSEntityDescription.entity(forEntityName: "Player", in:managedContext)
                                    
                                    let playerObject = Player(entity: entity!, insertInto: managedContext)
                                    
                                    if let personQuery = player.value(forKey: "person") as? PFObject {
                                        let person = try personQuery.fetch()
                                        
                                        playerObject.first_name = person.value(forKey: "first_name") as? String
                                        playerObject.last_name = person.value(forKey: "last_name") as? String
                                        print(player)
                                        if let position = player.value(forKey: "position") as? NSNumber {
                                            playerObject.position = position
                                        }
                                        if let row = player.value(forKey: "row") as? NSNumber {
                                            playerObject.row = row
                                        }
                                        playerObject.id = player.objectId
                                        if let userImageFile = person["photo"] as? PFFile {
                                            playerObject.photo = userImageFile.url
                                        }
                                        
                                        teamObject.addToPlayers(playerObject)
                                    }
                                
                                } catch let error as NSError  {
                                    print("Could not save \(error), \(error.userInfo)")
                                }
                                
                            }
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                        
                    }
                    do {
                        try managedContext.save()
                        
                        self.dismiss(animated: true, completion: nil)
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                    self.setupTeamControllers()
                }
            }
            
            
            let playerQuery = PFQuery(className: "team")
            playerQuery.whereKey("players", equalTo: person)
            playerQuery.includeKey("players")
            
            playerQuery.findObjectsInBackground{
                (objects, error) -> Void in
                
                if error == nil {
                    print(objects)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext
                    let teamEntity =  NSEntityDescription.entity(forEntityName: "Team", in:managedContext)
                    
                    for object in objects! {
                        let teamObject = Team(entity: teamEntity!, insertInto: managedContext)
                        
                        teamObject.name = object.value(forKey: "name") as! String?
                        teamObject.formation = object.value(forKey: "formation") as? [NSNumber]
                        teamObject.id = object.objectId
                        teamObject.my_role = "player"
                        
                        //                    if let image = self.teamImage {
                        //                        if let data = UIImagePNGRepresentation(image) {
                        //                            let filename = self.getDocumentsDirectory().appendingPathComponent("\(team.objectId).png")
                        //                            try? data.write(to: filename)
                        //                        }
                        //                    }
                        
                        let players = object.value(forKey: "player_info") as! PFRelation
//                        players.includeKey("person")
                        
                        let playerQuery = players.query()
                        
                        do {
                            let playerObjects = try playerQuery.findObjects()
                            
                            for player in playerObjects {
                                let entity =  NSEntityDescription.entity(forEntityName: "Player", in:managedContext)
                                
                                let playerObject = Player(entity: entity!, insertInto: managedContext)
                                
                                print(player)
                                
                                playerObject.first_name = player.value(forKey: "first_name") as? String
                                playerObject.last_name = player.value(forKey: "last_name") as? String
                                if let position = player.value(forKey: "position") as? NSNumber {
                                    playerObject.position = position
                                }
                                if let row = player.value(forKey: "row") as? NSNumber {
                                    playerObject.row = row
                                }
                                playerObject.id = player.objectId
                                
                                teamObject.addToPlayers(playerObject)
                            }
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                    }
                    do {
                        try managedContext.save()
                        
                        self.dismiss(animated: true, completion: nil)
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                    self.setupTeamControllers()
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = Int(myViewControllers.index(of: viewController)!)
        
        index += 1
        index = index % myViewControllers.count
        if index == 0 {
            return nil
        }
        return myViewControllers[index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = Int(myViewControllers.index(of: viewController)!)
        
        if index == 0 {
            return nil
        }
        index -= 1
        index = index % myViewControllers.count
        return myViewControllers[index]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return myViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
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
