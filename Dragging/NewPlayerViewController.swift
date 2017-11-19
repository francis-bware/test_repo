//
//  NewPlayerViewController.swift
//  Dragging
//
//  Created by francis gallagher on 18/10/16.
//  Copyright © 2016 Testing. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import Haneke
import Parse
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage

@objc protocol NewPlayerDelegate {
    func addedNewPlayer(_ player : Player?)
}

class NewPlayerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var phoneTextField: HoshiTextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var profilePicButton: UIButton!
    var delegate : NewPlayerDelegate?
    
    @IBOutlet weak var firstNameTextField: HoshiTextField!
    @IBOutlet weak var lastNameTextField: HoshiTextField!
    
    var team : Team?
    var profileImage : UIImage?
    
    var position = 0
    var row = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profilePicButton.layer.cornerRadius = 50
        profilePicButton.clipsToBounds = true
        
        scrollView.contentSize = CGSize(width: 0, height: 650)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addProfilePicAction(_ sender: AnyObject) {
        let alertController: UIAlertController = UIAlertController(title: "How would you like to add this player's photo?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let photoAction: UIAlertAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) -> () in
            
            if UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerControllerSourceType.camera) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                
                self.present(imagePicker, animated: true,
                             completion: nil)
            }
        })
        let existingAction: UIAlertAction = UIAlertAction(title: "Use Existing", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) -> () in
            
            if UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerControllerSourceType.photoLibrary) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = true
                
                self.present(imagePicker, animated: true,
                             completion: nil)
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(photoAction)
        alertController.addAction(existingAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "Player", in:managedContext)
        
//        let id = Int(arc4random_uniform(100000) + 1) as NSNumber
//        
//        let player = Player(entity: entity!, insertInto: managedContext)
//        
//        player.first_name = firstNameTextField.text
//        player.last_name = lastNameTextField.text
//        player.position = position as NSNumber?
//        player.row = row as NSNumber?
//        player.id = id
//        
//        if let image = profileImage {
//            if let data = UIImagePNGRepresentation(image) {
//                let filename = getDocumentsDirectory().appendingPathComponent("\(id).png")
//                try? data.write(to: filename)
//            }
//        }
//        
//        team?.addToPlayers(player)
//        
//        do {
//            try managedContext.save()
//            
//            delegate?.addedNewPlayer(player)
//            self.dismiss(animated: true, completion: nil)
//        } catch let error as NSError  {
//            print("Could not save \(error), \(error.userInfo)")
//        }
//        
        
        
        
        let ref = Database.database().reference(withPath: "player")
        
        
        ref.childByAutoId().setValue(["first_name" : self.firstNameTextField.text, "last_name" : self.lastNameTextField.text, self.team!.id! : 1, "position" : [0, 0], "phone" : self.phoneTextField.text, "email" : self.emailTextField.text] as Dictionary, withCompletionBlock: {(error, ref) -> Void in
            
            if self.profileImage != nil {
                let storage = Storage.storage()
                
                // Create a root reference
                let storageRef = storage.reference()
                
                let localFile = URL(string: "path/to/image")!
                
                // Create a reference to the file you want to upload
                let sergioRef = storageRef.child("images/\(ref.key).jpg")
                
                if let imageData = UIImageJPEGRepresentation(self.profileImage!, 1.0) {
                    // Upload the file to the path "images/rivers.jpg"
                    let uploadTask = sergioRef.putData(imageData, metadata: nil) { (metadata, error) in
                        guard let metadata = metadata else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let downloadURL = metadata.downloadURL()?.absoluteString
                        ref.updateChildValues(["photo" : downloadURL])
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
        
        
//        self.dismiss(animated: true, completion: nil)
        
//        let teamFetch = PFQuery(className: "team")
//
//        teamFetch.whereKey("objectId", equalTo: team!.id!)
//        teamFetch.getFirstObjectInBackground{(object, error) -> Void in
//            if error == nil{
//                if let teamObject = object {
//                    let friend = PFObject(className: "person")
//                    friend.setValue(self.firstNameTextField.text, forKey: "first_name")
//                    friend.setValue(self.lastNameTextField.text, forKey: "last_name")
//                    //        friend.setValue(emailLabel.text, forKey: "email")
//                    //        friend.setValue(sexLabel.text, forKey: "gender")
//                    //        friend.setValue(mobileLabel.text, forKey: "phone_number")
//                    if let image = self.profileImage {
//                        if let data = UIImagePNGRepresentation(image) {
//                            let pfphoto = PFFile(name: "Image.jpg", data: data)
//                            friend.setValue(pfphoto, forKey: "photo")
//                        }
//                    }
//                    let players = teamObject.relation(forKey: "players")
//                    players.add(friend)
//
//                    let friendPlayer = PFObject(className: "team_person")
//                    friendPlayer.setValue(friend, forKey: "person")
//                    friendPlayer.setValue("Striker", forKey: "position_name")
//                    friendPlayer.setValue(0, forKey: "position")
//                    friendPlayer.setValue(0, forKey: "row")
//
//                    friendPlayer.saveInBackground { (_, er) in
//                        if !(er != nil) {
//                            let playerInfo = teamObject.relation(forKey: "player_info")
//                            playerInfo.add(friendPlayer)
//
//                            teamObject.saveInBackground { (_, er) in
//                                if !(er != nil) {
//                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//                                    let managedContext = appDelegate.managedObjectContext
//
//                                    let entity =  NSEntityDescription.entity(forEntityName: "Player", in:managedContext)
//
//                                    let id = Int(arc4random_uniform(100000) + 1) as NSNumber
//
//                                    let player = Player(entity: entity!, insertInto: managedContext)
//
//                                    player.first_name = self.firstNameTextField.text
//                                    player.last_name = self.lastNameTextField.text
//                                    player.position = self.position as NSNumber?
//                                    player.row = self.row as NSNumber?
//                                    //player.id = id
//
//
//                                    self.team?.addToPlayers(player)
//
//                                    do {
//                                        try managedContext.save()
//
//                                        self.delegate?.addedNewPlayer(player)
//                                        self.dismiss(animated: true, completion: nil)
//                                    } catch let error as NSError  {
//                                        print("Could not save \(error), \(error.userInfo)")
//                                    }
//
//                                } else {
//                                    // Something went wrong
//                                }
//                            }
//                        } else {
//                            // Something went wrong
//                        }
//                    }
//                }
//            }
//        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePicButton.contentMode = .scaleAspectFit
            profilePicButton.setImage(pickedImage, for: .normal)
            
            profileImage = pickedImage
            
            
        } else  {
            if let pickedImage = info[UIImagePickerControllerOriginalImage]
            as? UIImage {
                profilePicButton.contentMode = .scaleAspectFit
                profilePicButton.setImage(pickedImage, for: .normal)
                
                profileImage = pickedImage
            }
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
