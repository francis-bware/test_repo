//
//  ConversationViewController.swift
//  Dragging
//
//  Created by francis gallagher on 12/04/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import SlackTextViewController
import Parse
import Messages
import MessageUI

class ConversationViewController: SLKTextViewController {
    
    var conversation : PFObject?
    var messages = [PFObject]()
    var searchResult: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView?.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.registerPrefixes(forAutoCompletion: ["@", "#"])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didChangeAutoCompletionPrefix(_ prefix: String, andWord word: String) {
        
        
    }
    
    override func didPressRightButton(_ sender: Any?) {
        
        let message = PFObject(className: "Message")
        
        message["message"] = self.textView.text
        message["conversation"] = conversation
        
        if let person = PFUser.current()?.object(forKey: "person") as? PFObject {
            message["sender"] = person
            message["name"] = person["first_name"]
            
            message.saveInBackground { (_, er) in
                if !(er != nil){
                    let indexPath = IndexPath(row: 0, section: 0)
                    let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
                    let scrollPosition: UITableViewScrollPosition = self.isInverted ? .bottom : .top
                    
                    self.tableView?.beginUpdates()
                    self.messages.insert(message, at: 0)
                    self.tableView?.insertRows(at: [indexPath], with: rowAnimation)
                    self.tableView?.endUpdates()
                    
                    self.tableView?.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
                    
                    self.tableView?.reloadRows(at: [indexPath], with: .automatic)
                    
                    super.didPressRightButton(sender)
                }
            }
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

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return self.messages.count
        } else {
            if let searchResult = self.searchResult {
                return searchResult.count
            }
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            return self.messageCellForRowAtIndexPath(indexPath)
        }
        else {
            return self.autoCompletionCellForRowAtIndexPath(indexPath)
        }
    }
    
    func messageCellForRowAtIndexPath(_ indexPath: IndexPath) -> MessageTableViewCell {
        
        let cell = self.tableView?.dequeueReusableCell(withIdentifier: "cell") as! MessageTableViewCell
        
        if cell.gestureRecognizers?.count == nil {
     //       let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MessageViewController.didLongPressCell(_:)))
//            cell.addGestureRecognizer(longPress)
        }
        
        let message = self.messages[(indexPath as NSIndexPath).row]
        
        cell.titleLabel.text =  message["name"] as! String?
        cell.bodyLabel.text = message["message"] as! String?
        let person = message["sender"] as! PFObject
        if let imageString = person["photo"] as? PFFile {
            print(imageString)
            print(imageString.url)
            cell.profilePic?.hnk_setImageFromURL(NSURL(string: imageString.url!)! as URL)
        } else {
            cell.profilePic?.image = UIImage(named: "20801.png")
        }
//        cell.indexPath = indexPath
//        cell.usedForMessage = true
        
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        cell.transform = (self.tableView?.transform)!
        
        return cell
    }
    
    func autoCompletionCellForRowAtIndexPath(_ indexPath: IndexPath) -> MessageTableViewCell {
        
        let cell = self.autoCompletionView.dequeueReusableCell(withIdentifier: "cell") as! MessageTableViewCell
//        cell.indexPath = indexPath
        cell.selectionStyle = .default
        
        guard let searchResult = self.searchResult else {
            return cell
        }
        
        guard let prefix = self.foundPrefix else {
            return cell
        }
        
        var text = searchResult[(indexPath as NSIndexPath).row]
        
        if prefix == "#" {
            text = "# " + text
        } else if prefix == ":" || prefix == "+:" {
            text = ":\(text):"
        }
        
        cell.titleLabel.text = text
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.tableView {
            let message = self.messages[(indexPath as NSIndexPath).row]
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .left
            
//            let pointSize = MessageTableViewCell.defaultFontSize()
            
            let attributes = [
                NSFontAttributeName : UIFont.systemFont(ofSize: 17),
                NSParagraphStyleAttributeName : paragraphStyle
            ]
            
            var width = tableView.frame.width-40
            width -= 25.0
            
            let titleBounds = (message["name"] as! NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            let bodyBounds = (message["message"] as! NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            if (message["message"] as! String).characters.count == 0 {
                return 0
            }
            
            var height = titleBounds.height
            height += bodyBounds.height
            height += 40
            
//            if height < kMessageTableViewCellMinimumHeight {
//                height = kMessageTableViewCellMinimumHeight
//            }
            
            return height
        }
        else {
            return 44//kMessageTableViewCellMinimumHeight
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.autoCompletionView {
            
            guard let searchResult = self.searchResult else {
                return
            }
            
            var item = searchResult[(indexPath as NSIndexPath).row]
            
            if self.foundPrefix == "@" && self.foundPrefixRange.location == 0 {
                item += ":"
            }
            else if self.foundPrefix == ":" || self.foundPrefix == "+:" {
                item += ":"
            }
            
            item += " "
            
            self.acceptAutoCompletion(with: item, keepPrefix: true)
        }
    }
}
