//
//  FindDuelViewController.swift
//  Square Up
//
//  Created by Ty Victorson on 3/20/17.
//  Copyright © 2017 Unown Studios. All rights reserved.
//

import UIKit

class FindDuelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // adds the city name for the title and the station name to the subtitle
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
