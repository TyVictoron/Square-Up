//
//  ViewController.swift
//  Square Up
//
//  Created by Ty Victorson on 3/16/17.
//  Copyright © 2017 Unown Studios. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class ViewController: UIViewController, MPCManagerDelegate{
    
   
    
    internal func disconnect() {
        
        print("Disconnected")
    }


    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
       // appDelegate.mpcManager.disconnect
        // Do any additional setup after loading the view.
        //appDelegate.mpcManager.session.cancelConnectPeer(appDelegate.mpcManager.peer)
        //MCSession.disconnect(appDelegate.mpcManager.session)
        appDelegate.mpcManager.session.disconnect()
        appDelegate.mpcManager.browser.stopBrowsingForPeers()
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
            self.performSegue(withIdentifier: "gameSegue", sender: self)
        }
        
    }

}
