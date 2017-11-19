//
//  PlayerFormationView.swift
//  Dragging
//
//  Created by francis gallagher on 3/01/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import CoreData

@objc protocol PlayerFormationDelegate {
    func addNewPlayer(_ view : PlayerDragView?)
    func viewPlayerProfile(_ player : Player?)
}

class PlayerFormationView: UIView, UIGestureRecognizerDelegate {
    
    var team : Team?
    
    var parentController : TeamSummaryViewController?
    var delegate : PlayerFormationDelegate?
    
    var substituteViews = [UIView]()
    let manager = OBDragDropManager.shared()
    let reservesView = UIScrollView()
    let addPlayerView = UIButton(type: .custom)

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func populatePlayers(sport : String, players : [Player], formation : [Int]) {
        for view in self.subviews {
            if view.restorationIdentifier != "background" && view.restorationIdentifier != "tacticsView" {
                view.removeFromSuperview()
            }
        }
        
        var aboveView = PlayerRowView()
        
        for j in 1...formation.count {
            var images = [UIView]()
            let count = formation[j-1]
            
            for i in 1...count {
                let view = PlayerDragView(frame: CGRect(x: 0, y: 0, width: 36, height: 84))
                
                var filteredPlayers = players.filter({$0.row == NSNumber(value: j) && $0.position == NSNumber(value: i)})
                if filteredPlayers.count > 0 {
                    let player = filteredPlayers[0]
                    
                    if let imageString = player.photo {
                        view.imageView?.hnk_setImageFromURL(NSURL(string: imageString)! as URL)
                    } else {
                        view.imageView?.image = UIImage(named: "avatar.png")
                    }
                    view.namelabel?.text = player.first_name
                    view.player = player
                    
                    let longPress = UILongPressGestureRecognizer()
//                    longPress.minimumPressDuration = 0.2
                    let longPressRecognizer = manager?.createDragDropGestureRecognizer(with: longPress.classForCoder, source: parentController as OBOvumSource!)
                    if self.team!.owner {
                        view.addGestureRecognizer(longPressRecognizer!)
                    }
                    
                    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewPlayer(_:)))
                    view.addGestureRecognizer(tapRecognizer)
                } else {
//                    let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(addNewPlayerFromGesture(_:)))
//                    view.addGestureRecognizer(tapRecogniser)
////                    view.imageView?.image = UIImage(named: "plus.png")
//                    view.imageView?.backgroundColor = UIColor(red: CGFloat(42/255.0), green: CGFloat(202/255.0), blue: CGFloat(208/255.0), alpha: 1.0)
//                    
//                    view.imageView?.frame = CGRect(x: 20, y: 20, width: 20, height: 20)
//                    view.imageView?.layer.cornerRadius = 10
                }
                
                view.setAvailability()
                
                self.addSubview(view)
                images.append(view)
                
                view.row = j
                view.position = i
                
                view.dropZoneHandler = parentController as OBDropZone!
            }
            
            let playerRow = PlayerRowView(frame: CGRect(x: 0, y: 0, width: 0, height: 36))
            
            self.addSubview(playerRow)
            let offset = (80 * (j-1)) + 10
            playerRow.autoAlignAxis(toSuperviewAxis: .vertical)
            playerRow.autoPinEdge(.top, to: .top, of: self, withOffset: CGFloat(offset))
            playerRow.autoPinEdge(.right, to: .right, of: self)
            playerRow.autoPinEdge(.left, to: .left, of: self)
            playerRow.backgroundColor = UIColor.clear
            playerRow.autoSetDimension(.height, toSize: 84)
            playerRow.dropZoneHandler = parentController as OBDropZone!
            
            let stackView = UIStackView(arrangedSubviews: images)
            stackView.spacing = 15
            stackView.dropZoneHandler = parentController as OBDropZone!
            playerRow.addSubview(stackView)
            stackView.autoPinEdge(.top, to: .top, of: playerRow)
            stackView.autoAlignAxis(toSuperviewAxis: .vertical)
            stackView.autoSetDimension(.height, toSize: 84)
            playerRow.stackView = stackView
            
            aboveView = playerRow
        }
        
        let reservesBackground = UIView()
        reservesBackground.backgroundColor = UIColor.darkGray
        reservesBackground.layer.cornerRadius = 5
        reservesBackground.clipsToBounds = true
        self.addSubview(reservesBackground)
        reservesBackground.autoPinEdge(.top, to: .bottom, of: aboveView, withOffset: 24)
        reservesBackground.autoPinEdge(.left, to: .left, of: self, withOffset: 5)
        reservesBackground.autoPinEdge(.right, to: .right, of: self, withOffset: -5)
        reservesBackground.autoSetDimension(.height, toSize: 92)
        
        let subsLabel = UILabel()
        subsLabel.text = "SUBS"
        subsLabel.font = UIFont.systemFont(ofSize: 10)
        subsLabel.textColor = UIColor(red: CGFloat(48/255.0), green: CGFloat(218/255.0), blue: CGFloat(224/255.0), alpha: 1.0)
        reservesBackground.addSubview(subsLabel)
        subsLabel.autoPinEdge(.top, to: .top, of: reservesBackground, withOffset: 0)
        subsLabel.autoPinEdge(.left, to: .left, of: reservesBackground, withOffset: 3)
        subsLabel.autoSetDimension(.width, toSize: 30)
        
        reservesView.backgroundColor = UIColor.clear
        reservesBackground.addSubview(reservesView)
        reservesView.autoPinEdge(.top, to: .top, of: reservesBackground, withOffset: 0)
        reservesView.autoPinEdge(.left, to: .left, of: reservesBackground, withOffset: 0)
        reservesView.autoPinEdge(.right, to: .right, of: reservesBackground, withOffset: 0)
        reservesView.autoSetDimension(.height, toSize: 92)
        
        addPlayerView.autoSetDimensions(to: CGSize(width: 60, height: 60))
        addPlayerView.backgroundColor = UIColor.white
        addPlayerView.layer.cornerRadius = 30
        addPlayerView.clipsToBounds = true
        addPlayerView.contentMode = UIViewContentMode.scaleAspectFill
        addPlayerView.setImage(UIImage(named: "plus.png"), for: .normal)
        addPlayerView.addTarget(self, action: #selector(addNewPlayer), for: .touchUpInside)
        
//        self.addSubview(view)
        
        reservesView.dropZoneHandler = parentController as OBDropZone!
        
//        reservesView.addSubview(addPlayerView)
//        addPlayerView.autoAlignAxis(.horizontal, toSameAxisOf: reservesView)
//        addPlayerView.autoPinEdge(.top, to: .top, of: reservesView, withOffset: 8)
//        addPlayerView.autoPinEdge(.left, to: .right, of: subsLabel, withOffset: 0)
        
        var filteredPlayers = players.filter({$0.row == NSNumber(value: 0) || $0.row == NSNumber(value: -1)})
        filteredPlayers = filteredPlayers.sorted(by: {Int($0.row!) > Int($1.row!)})
        
        self.resetSubs(filteredPlayers)
        
        self.autoPinEdge(.bottom, to: .bottom, of: reservesView, withOffset: 5)
    }
    
    func resetSubs(_ players : [Player]) {
        for view in substituteViews {
            view.removeFromSuperview()
        }
        
        var previousView = UIView()
        previousView = reservesView
        
        for player in players {
            let playerView = PlayerDragView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
            
            if let imageString = player.photo {
                playerView.imageView?.hnk_setImageFromURL(NSURL(string: imageString)! as URL)
            } else {
                playerView.imageView?.image = UIImage(named: "avatar.png")
            }
            playerView.player = player
            
            playerView.namelabel?.text = player.first_name
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewPlayer(_:)))
            playerView.addGestureRecognizer(tapRecognizer)
            
            let longPress = UILongPressGestureRecognizer()
//            longPress.minimumPressDuration = 0.3
            longPress.delegate = self;
            let longPressRecognizer = manager?.createDragDropGestureRecognizer(with: longPress.classForCoder, source: parentController as OBOvumSource!)
            if self.team!.owner {
                playerView.addGestureRecognizer(longPressRecognizer!)
            }
            
            reservesView.addSubview(playerView)
//            playerView.autoAlignAxis(.horizontal, toSameAxisOf: reservesView)
            if previousView == reservesView {
                playerView.autoPinEdge(.left, to: .left, of: previousView, withOffset: 30)
            } else {
                playerView.autoPinEdge(.left, to: .right, of: previousView, withOffset: 12)
            }
            playerView.autoPinEdge(.top, to: .top, of: reservesView, withOffset: 8)
            
            playerView.row = 0
            playerView.position = 0
            
            playerView.dropZoneHandler = parentController as OBDropZone!
            substituteViews.append(playerView)
            
            playerView.setAvailability()
            
            previousView = playerView
        }
        
        let width = players.count * 72
        self.reservesView.contentSize = CGSize(width: width + 100, height: 0)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func addNewPlayer() {
        delegate?.addNewPlayer(nil)
    }
    
    func viewPlayer(_ sender: UITapGestureRecognizer) {
        if let playerView = sender.view as? PlayerDragView {
            delegate?.viewPlayerProfile(playerView.player)
        }
    }
    
    func addNewPlayerFromGesture(_ sender: UITapGestureRecognizer) {
        if let playerView = sender.view as? PlayerDragView {
            delegate?.addNewPlayer(playerView)
        }
    }
}
