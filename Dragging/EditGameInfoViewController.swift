//
//  EditGameInfoViewController.swift
//  Dragging
//
//  Created by francis gallagher on 8/11/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit

class EditGameInfoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var titleView: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textView.isScrollEnabled = false
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeAction))
        closeButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItems = [closeButton]
        
        self.title = "Match Info"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        textView.delegate = self
        textView.text = "Enter info..."
        textView.textColor = .lightGray
    }
    
    func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Enter info...")
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Enter info..."
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
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
