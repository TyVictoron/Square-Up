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
import GameKit

class ViewController: UIViewController, MPCManagerDelegate, GKGameCenterControllerDelegate{
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    var score = 0
    
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    let LEADERBOARD_ID = "SquareUpLB.ID"
    
    
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
        
        // Call the GC authentication controller
        authenticateLocalPlayer()
        
        // Submit score to GC leaderboard
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(score)
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error)
            }
        }
    }
    
    // Delegate to dismiss the GC controller
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func GameCenterButton(_ sender: Any) {
        
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
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
