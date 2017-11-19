//
//  TakePhotoViewController.swift
//  Dragging
//
//  Created by francis gallagher on 8/03/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import Haneke
import Parse

class TakePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user : PFUser?
    var person : PFObject?
    @IBOutlet weak var profileImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profileImage.layer.cornerRadius = 100
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor(red: CGFloat(48/255.0), green: CGFloat(218/255.0), blue: CGFloat(224/255.0), alpha: 1.0).cgColor
        profileImage.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhotoAction(_ sender: AnyObject) {
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
    }

    @IBAction func uploadPhoto(_ sender: AnyObject) {
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
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = pickedImage
            
            self.dismiss(animated: true, completion: {
                if self.person != nil {
                    if let data = UIImagePNGRepresentation(pickedImage) {
                        let pfphoto = PFFile(name: "Image.jpg", data: data)
                        self.person?.setValue(pfphoto, forKey: "photo")
                        self.person?.saveInBackground{ (_, er) in
                            if !(er != nil) {
                                if self.user != nil {
                                    // Signing up using the Parse API
                                    self.user?.setValue(self.person, forKey: "person")
                                    self.user?.signUpInBackground {
                                        (success, error) -> Void in
                                        if let error = error as NSError? {
                                            let errorString = error.userInfo["error"] as? NSString
                                            print(errorString)
                                        } else {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                }
                            } else {
                                // Something went wrong
                                print(er)
                            }
                        }
                    }
                }
                
            })
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
