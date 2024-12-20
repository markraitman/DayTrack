//
//  ViewController.swift
//  DayTrack
//
//  Created by Марк Райтман on 16.12.2024.
//

import UIKit
import CalendarKit
import EventKit

class CalendarViewController: DayViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Calendar"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }

}

