//
//  ViewController.swift
//  Square Up
//
//  Created by Ty Victorson on 3/16/17.
//  Copyright © 2017 Unown Studios. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData

class ViewController: UIViewController, MPCManagerDelegate{
    
    @IBOutlet weak var duelsWonLabel: UILabel!
    var duelsWon = 0
    
    internal func disconnect() {
        print("Disconnected")
    }


    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults: UserDefaults = UserDefaults.standard
        let savedScore = defaults.integer(forKey: "highScore")
        duelsWon = savedScore
        
        duelsWonLabel.text = "Duels Won: \(duelsWon)"
        
        // disconnects session
        appDelegate.mpcManager.session.disconnect()
    }
   
    // both reload the data in the table view
    func foundPeer()
    {
        print("foundPeer")
    }
    
    func lostPeer()
    {
        print("lostPeer")
    }
    
    // if the device can connect to another device create a pop up and allow player to join
    func invitationWasReceived(fromPeer: String)
    {
        print("invitationWasReceived")
        //appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to Duel!", preferredStyle: UIAlertControllerStyle.alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
        }
        let decline = UIAlertAction(title: "Decline", style: .default) { (alertAction) in
            print("decline")
        }
        
        alert.addAction(acceptAction)
        alert.addAction(decline)
        
        OperationQueue.main.addOperation { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // called if invitation was accepted and take player to game view
    func connectedWithPeer(peerID: MCPeerID)
    {
        print("connectedWithPeer")
        OperationQueue.main.addOperation {
            let fdvc = self.storyboard?.instantiateViewController(withIdentifier: "FindDVC") as! FindDuelViewController
            fdvc.duelsWon = self.duelsWon
            self.performSegue(withIdentifier: "gameSegue", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FDVC") {
            let fdvc = self.storyboard?.instantiateViewController(withIdentifier: "FindDVC") as! FindDuelViewController
            fdvc.duelsWon = duelsWon
        }
    }

}
