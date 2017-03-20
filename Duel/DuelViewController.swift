//
//  DuelViewController.swift
//  Square Up
//
//  Created by Ty Victorson on 3/16/17.
//  Copyright © 2017 Unown Studios. All rights reserved.
//

import UIKit

class DuelViewController: UIViewController {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var fireButton: UIButton!
    var timer = Timer()
    var time = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countLabel.text = "3"
        fireButton.isHidden = true
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DuelViewController.update), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func fireButtonAction(_ sender: Any) {
        
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
}
