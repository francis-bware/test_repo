//
//  TeamLogoSelectViewController.swift
//  Dragging
//
//  Created by francis gallagher on 12/03/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import MobileCoreServices

class TeamLogoSelectViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var colorScrollView: UIScrollView!

    @IBOutlet weak var scrollSelectTitle: UILabel!
    @IBOutlet weak var logoPhotoButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var tshirtView: UIImageView!
    var teamImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tshirtView.image? = (tshirtView.image?.withRenderingMode(.alwaysTemplate))!
        tshirtView.tintColor = UIColor.white
        
        logoPhotoButton.layer.borderColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0).cgColor
        logoPhotoButton.layer.borderWidth = 1
        
        logoImageView.layer.cornerRadius = 60
        logoImageView.layer.borderColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0).cgColor
        logoImageView.layer.borderWidth = 2
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.pickColor(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func pickColor(_ sender: UITapGestureRecognizer) {
        let colorView = ColorPickerViewController()
        self.show(colorView, sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takeLogoPhoto(_ sender: AnyObject) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.image = pickedImage
            
            teamImage = pickedImage
        }
        
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
