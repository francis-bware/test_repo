//
//  PlayerDragView.swift
//  Dragging
//
//  Created by francis gallagher on 18/10/16.
//  Copyright © 2016 Testing. All rights reserved.
//

import UIKit

class PlayerDragView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
     */
    
    let moneyView = UILabel()
    
    var row : Int?
    var position : Int?
    var imageView : UIImageView?
    var namelabel : UILabel?
    var player : Player?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoSetDimensions(to: CGSize(width: 60, height: 84))
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.contentMode = UIViewContentMode.scaleAspectFill
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        imageView?.layer.cornerRadius = 30
        imageView?.clipsToBounds = true
        imageView?.contentMode = UIViewContentMode.scaleAspectFill
        
        imageView?.clipsToBounds = true
        imageView?.layer.borderWidth = 1

        if player?.availability == "available" {
            imageView?.layer.borderColor = UIColor.green.cgColor
        } else if player?.availability == "unavailable" {
            imageView?.layer.borderColor = UIColor.red.cgColor
        } else if player?.availability == "unknown" {
            imageView?.layer.borderColor = UIColor.orange.cgColor
        } else {
            imageView?.layer.borderColor = UIColor(red: CGFloat(48/255.0), green: CGFloat(218/255.0), blue: CGFloat(224/255.0), alpha: 1.0).cgColor
        }
        
        self.addSubview(imageView!)
        
        namelabel = UILabel()
        namelabel?.font = UIFont.systemFont(ofSize: 12)
        namelabel?.textColor = UIColor.white
        self.addSubview(namelabel!)
        
        namelabel?.autoPinEdge(.top, to: .bottom, of: imageView!)
        namelabel?.autoAlignAxis(.vertical, toSameAxisOf: self)
        namelabel?.autoSetDimension(.height, toSize: 16)
        namelabel?.autoSetDimension(.height, toSize: 100)
        
    }
    
    func setAvailability() {
        if player?.availability == "available" {
            imageView?.layer.borderColor = UIColor.green.cgColor
        } else if player?.availability == "unavailable" {
            imageView?.layer.borderColor = UIColor.red.cgColor
        } else if player?.availability == "unknown" {
            imageView?.layer.borderColor = UIColor.orange.cgColor
        } else {
            imageView?.layer.borderColor = UIColor(red: CGFloat(48/255.0), green: CGFloat(218/255.0), blue: CGFloat(224/255.0), alpha: 1.0).cgColor
        }
        
        if player?.row == -1 {
            let context = CIContext(options: nil)
            
            let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
            currentFilter!.setValue(CIImage(image: imageView!.image!), forKey: kCIInputImageKey)
            let output = currentFilter!.outputImage
            let cgimg = context.createCGImage(output!,from: output!.extent)
            let processedImage = UIImage(cgImage: cgimg!)
            imageView?.image = processedImage
        }
        
        if player?.finance == "unpaid" {
            moneyView.layer.cornerRadius = 10
            moneyView.backgroundColor = UIColor.red
            moneyView.text = "$"
            moneyView.font = UIFont.systemFont(ofSize: 14)
            moneyView.textColor = UIColor.white
            moneyView.textAlignment = .center
            moneyView.clipsToBounds = true
            self.addSubview(moneyView)
            
            moneyView.autoSetDimensions(to: CGSize(width: 20, height: 20))
            moneyView.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
            moneyView.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
        } else {
            moneyView.removeFromSuperview()
        }
    }
}
