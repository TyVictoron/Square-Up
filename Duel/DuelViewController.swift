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
import CoreData
import GoogleMobileAds

class DuelViewController: UIViewController {
    
    var motionManager = CMMotionManager()

    @IBOutlet weak var countLabel: UILabel!
    
    var mcm = MPCManager()
    var bgm = AVAudioPlayer()
    var shot = AVAudioPlayer()
    var draw = AVAudioPlayer()
    var timer = Timer()
    var afterFireTimer = Timer()
    var time = 10
    var newTime = 0
    var canShoot = true
    var duelsWon = 0
    var dead = false
    var winLossText = ""
    var hasShot = false
    
    /// The interstitial ad.
    var interstitial: GADInterstitial!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let request = GADRequest()
        //request.testDevices = [ kGADSimulatorID , "756b788c48f23c1b559c95e5bd8d9abf" ]
        
        interstitial = createAndLoadInterstitial()
        
        let defaults: UserDefaults = UserDefaults.standard
        let savedScore = defaults.integer(forKey: "highScore")
        duelsWon = savedScore
        
        // assign sound and play it
        bgm = self.setupAudioPlayerWithFile("bgm", type:"mp3")
        bgm.play()
        
        shot = self.setupAudioPlayerWithFile("shot", type:"mp3")
        draw = self.setupAudioPlayerWithFile("Draw", type: "mp3")
        
        if appDelegate.mpcManager.session.connectedPeers.count > 0
        {
            print("viola")
        }
        
        countLabel.text = "Hold phone down."
        
        print("Duels Won: ", duelsWon)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data, error) in
            
            if let myData = data
            {
                if myData.acceleration.y > 0.8 && self.canShoot == true && self.appDelegate.mpcManager.session.connectedPeers.count > 0
                {
                    //print("holster position")
                    self.appDelegate.mpcManager.sendData(dataToSend: "Holstered")
                    if (self.appDelegate.mpcManager.holstered == true) {
                        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DuelViewController.update), userInfo: nil, repeats: true)
                        self.canShoot = false
                        self.countLabel.isHidden = true
                    }
                }
                
                if myData.acceleration.y < 0.15 && self.canShoot == false && self.time == 0 && self.view.backgroundColor != UIColor.red && self.hasShot == false
                {
                    //print("shooting position")
                    self.afterFireTimer.invalidate()
                    //self.appDelegate.mpcManager.sendData(dataToSend: "\(self.newTime)")
                    self.hasShot = true
                    
                    if (self.appDelegate.mpcManager.dead == true) {
                        
                        self.winLossText = "You Lost"
                        self.view.backgroundColor = UIColor.red
                        
                        let defaults: UserDefaults = UserDefaults.standard
                        defaults.set(self.duelsWon, forKey: "highScore")
                        defaults.synchronize()
                        
                        if self.interstitial.isReady {
                            self.interstitial.present(fromRootViewController: self)
                        } else {
                            print("Ad wasn't ready")
                        }
                        
                        let alert = UIAlertController(title: self.winLossText, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let playAgainAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) -> Void in
                            let svc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
                            self.canShoot = true
                            self.dead = false
                            self.time = 10
                            self.appDelegate.mpcManager.shot = false
                            self.appDelegate.mpcManager.dead = false
                            self.appDelegate.mpcManager.holstered = false
                            self.bgm.stop()
                            svc.duelsWon = self.duelsWon
                            self.present(svc, animated: true, completion: nil)
                        }
                        
                        alert.addAction(playAgainAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        self.appDelegate.mpcManager.shot = true
                        self.appDelegate.mpcManager.sendData(dataToSend: "shot") // send data 
                        self.view.backgroundColor = UIColor.green
                        self.winLossText = "You Won!"
                        // shooting stuffs
                        self.shot.play()
                        self.duelsWon += 1
                        
                        let defaults: UserDefaults = UserDefaults.standard
                        defaults.set(self.duelsWon, forKey: "highScore")
                        defaults.synchronize()
                        
                        if self.interstitial.isReady {
                            self.interstitial.present(fromRootViewController: self)
                        } else {
                            print("Ad wasn't ready")
                        }
                        
                        let alert = UIAlertController(title: self.winLossText, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let playAgainAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) -> Void in
                            let svc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
                            self.canShoot = true
                            self.dead = false
                            self.time = 10
                            self.appDelegate.mpcManager.shot = false
                            self.appDelegate.mpcManager.dead = false
                            self.appDelegate.mpcManager.holstered = false
                            self.bgm.stop()
                            svc.duelsWon = self.duelsWon
                            self.present(svc, animated: true, completion: nil)
                        }
                        
                        alert.addAction(playAgainAction)
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    }
                    
                }
                else if (self.time > 0 && myData.acceleration.y < 0.15 && self.canShoot == false) {
                    print("Too Early")
                    self.winLossText = "You Went Early"
                    
                    self.afterFireTimer.invalidate()
                    
                    self.view.backgroundColor = UIColor.red
                    
                    let defaults: UserDefaults = UserDefaults.standard
                    defaults.set(self.duelsWon, forKey: "highScore")
                    defaults.synchronize()
                    
                    if self.interstitial.isReady {
                        self.interstitial.present(fromRootViewController: self)
                    } else {
                        print("Ad wasn't ready")
                    }
                    
                    let alert = UIAlertController(title: self.winLossText, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let playAgainAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) -> Void in
                        let svc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
                        self.canShoot = true
                        self.dead = false
                        self.time = 10
                        self.appDelegate.mpcManager.shot = false
                        self.appDelegate.mpcManager.dead = false
                        self.appDelegate.mpcManager.shot = false
                        self.appDelegate.mpcManager.holstered = false
                        self.bgm.stop()
                        svc.duelsWon = self.duelsWon
                        self.present(svc, animated: true, completion: nil)
                    }
                    
                    alert.addAction(playAgainAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
 
            
        }
 
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-5788120822235976/4041699644")
        interstitial.delegate = self as? GADInterstitialDelegate
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    func update() {
        time -= 1
        if (time <= 0) {
            //countLabel.text = "FIRE!"
            self.bgm.stop()
            self.draw.play()
            timer.invalidate()
            
            // start shoot time timer
            self.afterFireTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(DuelViewController.update2), userInfo: nil, repeats: true)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        //countLabel.text = "\(time)"
    }
    
    func update2() {
        newTime += 1
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
    
    
    @IBAction func devButtonForSimulator(_ sender: Any) {
        
        self.appDelegate.mpcManager.sendData(dataToSend: "Holstered")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "homeVC") {
            let fdvc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
            fdvc.duelsWon = duelsWon
        }
    }
}
