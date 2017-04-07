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

class DuelViewController: UIViewController {
    
     var motionManager = CMMotionManager()

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var fireButton: UIButton!
    var bgm = AVAudioPlayer()
    var shot = AVAudioPlayer()
    var timer = Timer()
    var time = 10
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countLabel.text = "10"
        fireButton.isHidden = true
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DuelViewController.update), userInfo: nil, repeats: true)
        
        // assign sound and play it
        bgm = self.setupAudioPlayerWithFile("bgm", type:"mp3")
        bgm.play()
        
        shot = self.setupAudioPlayerWithFile("shot", type:"mp3")
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        motionManager.accelerometerUpdateInterval = 0.2
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data, error) in
            
            if let myData = data
            {
                print(myData)
            }
            
            
            
        }
    }
    
    @IBAction func fireButtonAction(_ sender: Any) {
        shot.play()
        appDelegate.mpcManager.shot = true
        bgm.stop()
        //go to next view
    }
    
    func update() {
        time -= 1
        if (time == 0) {
            countLabel.text = "FIRE!"
            fireButton.isHidden = false
            timer.invalidate()
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
}
