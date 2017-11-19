//
//  SettingsViewController.swift
//  Dragging
//
//  Created by francis gallagher on 26/02/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import Parse
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        try! Auth.auth().signOut()
        
        let loginViewController = LoginViewController()
        let navController = UINavigationController(rootViewController: loginViewController)
        navController.navigationBar.barTintColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0)
        self.present(navController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Boardingware Kiosk Account"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 200))
        
        
        let defaults = UserDefaults.standard
        
        let label = UILabel(frame: CGRect(x: 14,y: 10,width: 400,height: 20))
        
        label.text = Auth.auth().currentUser?.displayName
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.textColor = UIColor(red: CGFloat(0/255.0), green: CGFloat(0/255.0), blue: CGFloat(0/255.0), alpha: 1.0)
        
        view.addSubview(label)
        label.autoPinEdge(.left, to: .left, of: view)
        label.autoPinEdge(.right, to: .right, of: view)
        label.autoPinEdge(.top, to: .top, of: view, withOffset: 20)
        label.autoSetDimension(.height, toSize: 25)
        
        let subLabel = UILabel(frame: CGRect(x: 14,y: 10,width: 400,height: 20))
        
        
        subLabel.text = defaults.object(forKey: "staffEmail") as! String?
        subLabel.textAlignment = .center
        subLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        subLabel.textColor = UIColor(red: CGFloat(128/255.0), green: CGFloat(128/255.0), blue: CGFloat(128/255.0), alpha: 1.0)
        
        view.addSubview(subLabel)
        subLabel.autoPinEdge(.left, to: .left, of: view)
        subLabel.autoPinEdge(.right, to: .right, of: view)
        subLabel.autoPinEdge(.top, to: .bottom, of: label, withOffset: 10)
        //        subLabel.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: 10)
        subLabel.autoSetDimension(.height, toSize: 25)
        
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        try! Auth.auth().signOut()
        
        let loginViewController = LoginViewController()
        let navController = UINavigationController(rootViewController: loginViewController)
        navController.navigationBar.barTintColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0)
        self.present(navController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            cell!.selectedBackgroundView = backgroundView
        }
        
        for view in (cell?.contentView.subviews)! {
            view.removeFromSuperview()
        }
        
        cell?.accessoryType = .none
        
        cell?.textLabel?.textColor = UIColor(red: CGFloat(208/255.0), green: CGFloat(2/255.0), blue: CGFloat(27/255.0), alpha: 1.0)
        cell?.textLabel?.textAlignment = .center
        cell?.textLabel!.text = "Log Out"
        
        cell?.textLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell!.selectedBackgroundView = backgroundView
        
        cell?.layoutMargins = UIEdgeInsets.zero
        
        return cell!
    }
}
