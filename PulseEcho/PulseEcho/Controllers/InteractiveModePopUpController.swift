//
//  InteractiveModePopUpController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-10.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class InteractiveModePopUpController: BaseController {

    //STORYBOARD OUTLETS
    @IBOutlet weak var lblNextMove:UILabel?
    @IBOutlet weak var viewContent: UIView?
    
    
    //CLASS VARIABLES
    var nextMove: Int? {
        didSet {
            updateViews()
        }
    }
    
    var isShowing: Bool? {
        didSet {
            checkPopUp()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       let tapGesture = UITapGestureRecognizer(target: self, action: #selector(makeMeHealthy(_:)))
       tapGesture.numberOfTapsRequired = 1
       viewContent?.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    func updateViews() {
        guard let item = nextMove else  {
            return
        }
        
        let move = MovementType(rawValue: item)?.readableMovement
        lblNextMove?.text = move
    }
    
    func checkPopUp() {
        guard let item = isShowing else {
            return
        }
        
        if item {
            //self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func makeMeHealthy(_ sender: UITapGestureRecognizer) {
        let command = SPCommand.GetAcknowkedgePendingMovement()
        self.sendACommand(command: command, name: "SPCommand.GetAcknowkedgePendingMovement")
    }

}
