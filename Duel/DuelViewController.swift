//
//  DuelViewController.swift
//  Square Up
//
//  Created by Ty Victorson on 3/16/17.
//  Copyright © 2017 Unown Studios. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import AudioToolbox

class DuelViewController: UIViewController {
    
     var motionManager = CMMotionManager()

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    var mcm = MPCManager()
    var bgm = AVAudioPlayer()
    var shot = AVAudioPlayer()
    var timer = Timer()
    var time = arc4random_uniform(7) + 3
    var canShoot = true
    var duelsWon = 0
    var dead = false
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playAgainButton.isHidden = true
        homeButton.isHidden = true
        
        // assign sound and play it
        bgm = self.setupAudioPlayerWithFile("bgm", type:"mp3")
        bgm.play()
        
        shot = self.setupAudioPlayerWithFile("shot", type:"mp3")
        
        if appDelegate.mpcManager.session.connectedPeers.count > 0
        {
            print("viola")
        }
        
        appDelegate.mpcManager.sendData(dataToSend: "\(time)")
        
        time = UInt32(appDelegate.mpcManager.time)
        countLabel.text = "\(time)"
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        motionManager.accelerometerUpdateInterval = 0.2
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data, error) in
            
            if let myData = data
            {
                if myData.acceleration.y > 0.8 && self.canShoot == true && self.appDelegate.mpcManager.session.connectedPeers.count > 0
                {
                    print("holster position")
                    self.appDelegate.mpcManager.sendData(dataToSend: "Holstered")
                    if (self.appDelegate.mpcManager.holstered == true) {
                        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DuelViewController.update), userInfo: nil, repeats: true)
                        self.canShoot = false
                    }
                }
                if myData.acceleration.y < 0.15 && self.canShoot == false && self.time == 0 && self.view.backgroundColor != UIColor.red
                {
                    print("shooting position")
                    
                    if (self.appDelegate.mpcManager.dead == true) {
                        self.playAgainButton.isHidden = false
                        self.homeButton.isHidden = false
                        self.view.backgroundColor = UIColor.red
                        
                        //passes the data over to the gameover view without story board sugue
                        let svc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
                        svc.duelsWon = self.duelsWon
                    } else {
                        // shooting stuffs
                        self.shot.play()
                        self.appDelegate.mpcManager.shot = true
                        self.bgm.stop()
                        self.appDelegate.mpcManager.sendData(dataToSend: "shot")
                        
                        // activates buttons
                        self.playAgainButton.isHidden = false
                        self.homeButton.isHidden = false
                        self.duelsWon += 1
                        self.view.backgroundColor = UIColor.green
                        
                        //passes the data over to the gameover view without story board sugue
                        let svc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
                        svc.duelsWon = self.duelsWon + 1
                    }

                }
                else if (self.time != 0 && myData.acceleration.y < 0.15 && self.canShoot == false) {
                    print("Too Early")
                }
            }
            
            
            
        }
    }
    
    @IBAction func playAgainButtonAction(_ sender: Any) {
        self.playAgainButton.isHidden = true
        self.homeButton.isHidden = true
        canShoot = true
        self.view.backgroundColor = UIColor.darkGray
    }
    
    func update() {
        time -= 1
        if (time <= 0) {
            countLabel.text = "FIRE!"
            timer.invalidate()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        countLabel.text = "\(time)"
    }
    
    // Sound setup
    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer  {
        //1
        let path = Bundle.main.path(forResource: file as String, ofType:type as String)
        let url = URL(fileURLWithPath: path!)
        
        //2
        var audioPlayer:AVAudioPlayer?
        
        // 3
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            print("Player not available")
        }
        
        //4
        return audioPlayer!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "homeVC") {
            let fdvc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
            fdvc.duelsWon = duelsWon
        }
    }
}
