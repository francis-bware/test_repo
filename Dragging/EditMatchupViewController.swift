//
//  EditMatchupViewController.swift
//  Dragging
//
//  Created by francis gallagher on 5/04/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import MapKit
import MobileCoreServices
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase

class EditMatchupViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var awayLogo: UIImageView!
    @IBOutlet weak var homeLogo: UIImageView!
    var awayImage : UIImage?
    
    var oldMatchId : String?
    var team : Team?
    var awayTeam : Team?
    
    var myTeamNameField = UITextField()
    var oppositionField = UITextField()
    var matchOpposition : String?
    var locationField = UITextField()
    var matchLocation : String?
    var matchDate : Date?
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var awayNameButton: UIButton!
    @IBOutlet weak var selectAwayLogoButton: UIButton!
    
    var myPhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        homeLogo.layer.cornerRadius = 50
        awayLogo.layer.cornerRadius = 50
        
        let fileName = "\(team!.id!).png"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + fileName
        if let image = UIImage(contentsOfFile: path) {
            homeLogo.image = image
        } else {
            homeLogo.image = UIImage(named: "shield.png")
        }
        awayLogo.image = UIImage(named: "shield.png")
        
        homeLabel.text = team?.name
        
        self.homeLabel.text = team?.name
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editAction))
        editButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItems = [editButton]
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeAction))
        closeButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItems = [closeButton]
        
        self.title = "Next Match"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        if matchDate != nil {
            dateButton.setTitle(DateFormatters.fullDisplayFormat.string(from: self.matchDate!), for: .normal)
        }
        if matchOpposition != nil {
            awayNameButton.setTitle(matchOpposition, for: .normal)
        }
        if matchLocation != nil {
            locationButton.setTitle(matchLocation, for: .normal)
        }
    }
    
    func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func editAction() {
        
    }
    @IBAction func editMyTeamName(_ sender: Any) {
        let alert = UIAlertController(title: "My Team's Name", message: "Please enter your team's name below", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = self.team?.name
            self.myTeamNameField = textField
            textField.autocapitalizationType = .sentences
            
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: myTeamEntered))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func myTeamEntered(_ alert: UIAlertAction!){
        if let name = myTeamNameField.text {
            self.homeLabel.text = name
            
            let teamRef = Database.database().reference(withPath: "team").child(self.team!.id!)
            
            teamRef.updateChildValues(["name": name])
            
            self.team?.name = name
        }
    }
    
    @IBAction func editMyTeamLogo(_ sender: Any) {
        let alertController: UIAlertController = UIAlertController(title: "How would you like to add this your logo?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
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
                
                self.myPhoto = true
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
                
                self.myPhoto = true
                self.present(imagePicker, animated: true,
                             completion: nil)
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(photoAction)
        alertController.addAction(existingAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func selectAwayLogoAction(_ sender: AnyObject) {
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
                
                self.myPhoto = false
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
                
                self.myPhoto = false
                self.present(imagePicker, animated: true,
                             completion: nil)
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(photoAction)
        alertController.addAction(existingAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            if self.myPhoto {
                homeLogo.contentMode = .scaleAspectFit
                homeLogo.image = pickedImage
            } else {
                awayLogo.contentMode = .scaleAspectFit
                awayLogo.image = pickedImage
                
                awayImage = pickedImage
            }
        } else  {
            if let pickedImage = info[UIImagePickerControllerOriginalImage]
                as? UIImage {
                if self.myPhoto {
                    homeLogo.contentMode = .scaleAspectFit
                    homeLogo.image = pickedImage
                } else {
                    awayLogo.contentMode = .scaleAspectFit
                    awayLogo.image = pickedImage
                    
                    awayImage = pickedImage
                }
            }
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func awayNameAction(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Opposition", message: "Please enter your opponents name below", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Opposition"
            self.oppositionField = textField
            textField.autocapitalizationType = .sentences
            if let note = self.matchOpposition {
                self.oppositionField.text = note
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: oppositionEntered))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func oppositionEntered(_ alert: UIAlertAction!){
        if let location = oppositionField.text {
            matchOpposition = location
            awayNameButton.setTitle(matchOpposition, for: .normal)
        }
    }
    
    @IBAction func dateAction(_ sender: AnyObject) {
        var date = Date()
        
        if let savedDate = matchDate {
            date = savedDate
        }
        
        DatePickerDialog().show("Departure Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: date, datePickerMode: .dateAndTime) {
            (date) -> Void in
            self.matchDate = date
            self.dateButton.setTitle(DateFormatters.fullDisplayFormat.string(from: self.matchDate!), for: .normal)
        }
    }
    
    @IBAction func locationAction(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Location", message: "Please enter the location below", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Location"
            self.locationField = textField
            textField.autocapitalizationType = .sentences
            if let note = self.matchLocation {
                self.locationField.text = note
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: locationEntered))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationEntered(_ alert: UIAlertAction!){
        if let location = locationField.text {
            matchLocation = location
            locationButton.setTitle(matchLocation, for: .normal)
        }
    }
    @IBAction func confirmAction(_ sender: AnyObject) {
        let ref = Database.database().reference(withPath: "match")
        
//        ref.child(self.oldMatchId!).updateChildValues(["status" : "past"] as Dictionary)
        
        ref.childByAutoId().setValue(["awayTeam" : self.awayNameButton.titleLabel?.text, "homeTeam" : "Vas's Team", "date" : DateFormatters.utcFormat.string(from: self.matchDate!), "status" : "active", "ground" : self.locationField.text, team!.id! : 1] as Dictionary, withCompletionBlock: {(error, ref) -> Void in
            
            if self.awayImage != nil {
                let storage = Storage.storage()
                
                // Create a root reference
                let storageRef = storage.reference()
                
                // Create a reference to the file you want to upload
                let sergioRef = storageRef.child("images/\(ref.key).jpg")
                
                if let imageData = UIImageJPEGRepresentation(self.awayImage!, 1.0) {
                    // Upload the file to the path "images/rivers.jpg"
                    let uploadTask = sergioRef.putData(imageData, metadata: nil) { (metadata, error) in
                        guard let metadata = metadata else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let downloadURL = metadata.downloadURL()?.absoluteString
                        ref.updateChildValues(["awayPhoto" : downloadURL])
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
        
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

}
