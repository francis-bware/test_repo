//
//  FirstViewController.swift
//  Dragging
//
//  Created by francis gallagher on 30/09/16.
//  Copyright © 2016 Testing. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuthUI

class FirstViewController: UIViewController, OBOvumSource, OBDropZone {

    
    @IBOutlet weak var groundNameLabel: UILabel!
    @IBOutlet weak var awayNameLabel: UILabel!
    @IBOutlet weak var homeNameLabel: UILabel!
    @IBOutlet weak var awayLogoImage: UIImageView!
    @IBOutlet weak var homeLogoImage: UIImageView!
    
    var draggingView : PlayerDragView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "", image: UIImage(named: "calendar"), tag: 5)
        tabBarItem.selectedImage = UIImage(named: "calendar_active")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        homeLogoImage.layer.cornerRadius = 20
        awayLogoImage.layer.cornerRadius = 20
        groundNameLabel.layer.cornerRadius = 5
        awayNameLabel.layer.cornerRadius = 5
        homeNameLabel.layer.cornerRadius = 5
        groundNameLabel.clipsToBounds = true
        awayNameLabel.clipsToBounds = true
        homeNameLabel.clipsToBounds = true
        
        
        
        
        let manager = OBDragDropManager.shared()
        
        let array = [1, 3, 2, 4, 1]
        
        var aboveView = UIStackView()
        
        for j in 0...array.count - 1 {
            var images = [UIView]()
            let count = array[j]
            
            var playerDict = [:] as [Int : Player?]
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")

            fetchRequest.predicate = NSPredicate(format: "row = %d", j)
            
            do {
                let results = try managedContext.fetch(fetchRequest)
                
                let players = results as! [Player]
                
                for player in players {
                    playerDict[Int(player.position!)] = player
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            for i in 1...count {
                let view = PlayerDragView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
                
                if let player = playerDict[i] {
                    view.imageView?.image = UIImage(named: "20801.png")
                    view.player = player
                } else {
                    view.imageView?.image = UIImage(named: "Profile_Holder.png")
                }
    
                let panRecognizer = manager?.createDragDropGestureRecognizer(with: UIPanGestureRecognizer.classForCoder(), source: self)
                view.addGestureRecognizer(panRecognizer!)
                
                self.view.addSubview(view)
                images.append(view)
                
                view.row = j
                view.position = i
                
                view.dropZoneHandler = self
            }
            
            let stackView = UIStackView(arrangedSubviews: images)
            self.view.addSubview(stackView)
            stackView.autoAlignAxis(toSuperviewAxis: .vertical)
            let offset = 150 + (60 * j)
            stackView.autoPinEdge(.top, to: .top, of: self.view, withOffset: CGFloat(offset))
            stackView.spacing = 10
            stackView.backgroundColor = UIColor.white
            
            aboveView = stackView
        }
        
        
        let reservesView = UIScrollView()
        
        reservesView.backgroundColor = UIColor(red: CGFloat(80/255.0), green: CGFloat(97/255.0), blue: CGFloat(94/255.0), alpha: 1.0)
        reservesView.layer.cornerRadius = 5
        self.view.addSubview(reservesView)
        reservesView.autoPinEdge(.top, to: .bottom, of: aboveView, withOffset: 24)
        reservesView.autoPinEdge(.left, to: .left, of: self.view, withOffset: 5)
        reservesView.autoPinEdge(.right, to: .right, of: self.view, withOffset: -5)
        reservesView.autoSetDimension(.height, toSize: 50)
        
        let subsLabel = UILabel()
        subsLabel.text = "SUBS"
        subsLabel.font = UIFont.systemFont(ofSize: 10)
        subsLabel.textColor = UIColor(red: CGFloat(48/255.0), green: CGFloat(218/255.0), blue: CGFloat(224/255.0), alpha: 1.0)
        reservesView.addSubview(subsLabel)
        subsLabel.autoPinEdge(.top, to: .top, of: reservesView, withOffset: 0)
        subsLabel.autoPinEdge(.left, to: .left, of: reservesView, withOffset: 3)
        subsLabel.autoSetDimension(.width, toSize: 30)
        
        let view = UIButton(type: .custom)
        
        view.autoSetDimensions(to: CGSize(width: 36, height: 36))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        view.contentMode = UIViewContentMode.scaleAspectFill
        view.setImage(UIImage(named: "export.png"), for: .normal)
        view.addTarget(self, action: #selector(addNewPlayer), for: .touchUpInside)
        
        self.view.addSubview(view)
        
        view.dropZoneHandler = self
        
        reservesView.addSubview(view)
        view.autoAlignAxis(toSuperviewAxis: .horizontal)
        view.autoPinEdge(.left, to: .right, of: subsLabel, withOffset: 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil {
            
        } else {
            let loginViewController = LoginViewController()
            
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    func addNewPlayer() {
        self.performSegue(withIdentifier: "showAddPlayerFromTeamView", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createOvum(from sourceView: UIView!) -> OBOvum! {
        let ovum = OBOvum()
        ovum.dataObject = sourceView.tag as NSNumber
        return ovum
    }
    
    func createDragRepresentation(ofSourceView sourceView: UIView!, in window: UIWindow!) -> UIView! {
        
        draggingView = sourceView as? PlayerDragView
        
        let frame  = window.convert(sourceView.frame, to: sourceView.window)
        
        let dragImage = UIImageView(frame: frame)
        dragImage.image = UIImage(named: "20801.png")
        dragImage.layer.cornerRadius = 18
        dragImage.clipsToBounds = true
        dragImage.contentMode = UIViewContentMode.scaleAspectFill
        return dragImage
    }
    
    func ovumEntered(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) -> OBDropAction {
        view.backgroundColor = UIColor.green
        return OBDropAction.copy
    }
    
    func ovumExited(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) {
        view.backgroundColor = UIColor.white
    }
    
    func ovumDropped(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) {
        
        let playerView = view as? PlayerDragView
        
        draggingView?.player?.row = playerView?.row as NSNumber?
        draggingView?.player?.position = playerView?.position as NSNumber?
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        do {
            try managedContext.save()
            
            let oldImage = draggingView?.imageView?.image
            let oldPlayer = draggingView?.player
            
            draggingView?.imageView?.image = playerView?.imageView?.image
            playerView?.imageView?.image = oldImage
            draggingView?.player = playerView?.player
            playerView?.player = oldPlayer
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        view.backgroundColor = UIColor.white
    }


}

