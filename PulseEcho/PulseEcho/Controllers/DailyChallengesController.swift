//
//  DailyChallengesController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-23.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class DailyChallengesController: BaseController {

    //STORYBOARD OUTLETS
    
    @IBOutlet weak var content: UIView?
    @IBOutlet weak var tabMenu: UIView?
    
    //CLASS VARIABLES
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cloudStatusIndicator()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
