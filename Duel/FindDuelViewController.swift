//
//  FindDuelViewController.swift
//  Square Up
//
//  Created by Ty Victorson on 3/20/17.
//  Copyright © 2017 Unown Studios. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class FindDuelViewController: UIViewController, MPCManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var selectOpponentLabel: UILabel?
    @IBOutlet weak var backDownLabel: UIButton!
    @IBOutlet weak var connectingLabel: UILabel!
    
    internal func disconnect() {
        print("Disconnected")
        
        // incase of connection fail
        self.selectOpponentLabel?.isHidden = false
        self.tableView.isHidden = false
        self.backDownLabel.isHidden = false
        self.connectingLabel.text = ""
        self.connectingLabel.isHidden = true
    }

    var duelsWon = 0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults: UserDefaults = UserDefaults.standard
        let savedScore = defaults.integer(forKey: "highScore")
        duelsWon = savedScore
        
        appDelegate.mpcManager.delegate = self
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        tableView.delegate = self
        tableView.dataSource = self
        
        print("Duels Won: ", duelsWon)
    }
    
    // both reload the data in the table view
    func foundPeer()
    {
        print("foundPeer")
        tableView.reloadData()
        
    }
    
    func lostPeer()
    {
        print("lostPeer")
        tableView.reloadData()
    }
    
    // if the device can connect to another device create a pop up and allow player to join
    func invitationWasReceived(fromPeer: String)
    {
        print("invitationWasReceived")
        appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to Duel!", preferredStyle: UIAlertControllerStyle.alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
            
            // hiding stuff here
            self.selectOpponentLabel?.isHidden = true
            self.tableView.isHidden = true
            self.backDownLabel.isHidden = true
            self.connectingLabel.text = "Connecting"
            self.connectingLabel.textColor = UIColor.red 
        }
        
        let decline = UIAlertAction(title: "Decline", style: .default) { (alertAction) in
            print("decline")
            
            self.selectOpponentLabel?.isHidden = false
            self.tableView.isHidden = false
            self.backDownLabel.isHidden = false
            self.connectingLabel.text = ""
            self.connectingLabel.isHidden = true
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
            let fdvc = self.storyboard?.instantiateViewController(withIdentifier: "gameSegue") as! DuelViewController
            fdvc.duelsWon = self.duelsWon
            self.performSegue(withIdentifier: "gameVC", sender: self)
        }
        
    }
    
    // table view set up
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.mpcManager.browser.invitePeer(appDelegate.mpcManager.foundPeers[indexPath.row], to: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel!.text! = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "gameVC") {
            let fdvc = self.storyboard?.instantiateViewController(withIdentifier: "gameSegue") as! DuelViewController
            fdvc.duelsWon = duelsWon
        }
    }

}
