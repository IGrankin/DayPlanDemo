//
//  ViewController.swift
//  DayPlanDemo
//
//  Created by admin on 13/12/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var backgroundDayPlanView: UIView!
    private var dayPlanView: DayPlanView = DayPlanView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayPlanView.frame = backgroundDayPlanView.bounds
        backgroundDayPlanView.addSubview(dayPlanView)
        // Do any additional setup after loading the view.
    }


}

