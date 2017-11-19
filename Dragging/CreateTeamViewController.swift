//
//  CreateTeamViewController.swift
//  Dragging
//
//  Created by francis gallagher on 30/12/16.
//  Copyright © 2016 Testing. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import Haneke
import ActionSheetPicker_3_0
import Parse
import FirebaseDatabase

class CreateTeamViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var nameTextField: HoshiTextField!
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var selectTeamButton: UIButton!
    @IBOutlet weak var sportButton: UIButton!
    var teamImage : UIImage?
    
    var sportField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = Database.database().reference()
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
    @IBAction func selectSportAction(_ sender: UIButton) {
        ActionSheetMultipleStringPicker.show(withTitle: "Select Your Sport", rows: [
            ["Cricket", "Football", "Rugby", "Other"]
            ], initialSelection: [0], doneBlock: {
                picker, indexes, values in
                
                print("values = \(values)")
                if let valueArray = values as? [String] {
                    if valueArray.count > 0 {
                        let sport = valueArray[0]
                        if sport == "Other" {
                            let alert = UIAlertController(title: "Other Sport", message: "Please enter below", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                                textField.placeholder = "Other..."
                                self.sportField = textField
                                textField.autocapitalizationType = .sentences
                            })
                            
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                            alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: self.sportEntered))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.sportButton.setTitle(sport, for: .normal)
                        }
                    }
                }
                
                return
            }, cancel: {
                ActionMultipleStringCancelBlock in return
            }, origin: sender)
    }
    
    func sportEntered(_ alert: UIAlertAction!){
        if let sport = sportField.text {
            self.sportButton.setTitle(sport, for: .normal)
        }
    }
    
    @IBAction func selectTeamPhotoAction(_ sender: UIButton) {
        let alertController: UIAlertController = UIAlertController(title: "How would you like to add this team's logo?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
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
                imagePicker.allowsEditing = false
                
                self.present(imagePicker, animated: true,
                             completion: nil)
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(photoAction)
        alertController.addAction(existingAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectTeamButton.contentMode = .scaleAspectFit
            selectTeamButton.setImage(pickedImage, for: .normal)
            
            teamImage = pickedImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveAction(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        let teamEntity =  NSEntityDescription.entity(forEntityName: "Team", in:managedContext)
        
        let id = Int(arc4random_uniform(10000000) + 1) as NSNumber
        
        
        let team = PFObject(className: "team")
        
        team["name"] = nameTextField.text
        
        let managers = team.relation(forKey: "managers")
        let person = PFUser.current()?.object(forKey: "person") as! PFObject
        managers.add(person)
        
        team.saveInBackground { (_, er) in
            if !(er != nil) {
                let teamObject = Team(entity: teamEntity!, insertInto: managedContext)
                
                teamObject.name = self.nameTextField.text
                teamObject.id = team.objectId
                
                if let image = self.teamImage {
                    if let data = UIImagePNGRepresentation(image) {
                        let filename = self.getDocumentsDirectory().appendingPathComponent("\(team.objectId).png")
                        try? data.write(to: filename)
                    }
                }
                
                do {
                    try managedContext.save()
                    
                    self.dismiss(animated: true, completion: nil)
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }

            } else {
                // Something went wrong
            }
        }
        
        
        
    }
    
    @IBAction func nextAction(_ sender: AnyObject) {
        
        self.ref.child("team").childByAutoId().setValue(["name" : nameTextField.text as! NSString,
                                                         "sport" : self.sportButton.titleLabel?.text as! NSString,
                                                         "numberOfPlayers" : NSNumber(value: 11),
                                                         "numberOfSubs" : NSNumber(value: 5)] as Dictionary)
        
        let registerView = TeamLogoSelectViewController()
        self.navigationController?.pushViewController(registerView, animated: true)
        
    }
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
