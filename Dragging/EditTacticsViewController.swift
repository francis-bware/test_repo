//
//  EditTacticsViewController.swift
//  Dragging
//
//  Created by francis gallagher on 14/06/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit

class EditTacticsViewController: UIViewController {

    var tactics = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func tableView(_ tableView:UITableView!, numberOfRowsInSection section:Int)->Int
    {
        return tactics.count + 1
    }
    
    func numberOfSectionsInTableView(_ tableView:UITableView!)->Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
            
            cell?.textLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
            cell?.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        }
        
        if indexPath.row == 0 {
            cell?.textLabel?.text = "Add tactic"
        }
        
        return cell!
    }

}
