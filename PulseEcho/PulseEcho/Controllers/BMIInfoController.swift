//
//  BMIInfoController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-19.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import PanModal
import FontAwesome_swift

class BMIInfoController: BaseController {
    
    //STORYBOARD OUTLETS

    @IBOutlet weak var lblBmiTitle: UILabel?
    @IBOutlet weak var lblWeight: UILabel?
    @IBOutlet weak var lblHeight: UILabel?
    @IBOutlet weak var lblClassify: UILabel?
    @IBOutlet weak var lblUnderweight: UILabel?
    @IBOutlet weak var lblHealthy: UILabel?
    @IBOutlet weak var lblObese: UILabel?
    @IBOutlet weak var lblOverweight: UILabel?
    @IBOutlet weak var imgUnderweight: UIImageView?
    @IBOutlet weak var imgHealthy: UIImageView?
    @IBOutlet weak var imgOverweight: UIImageView?
    @IBOutlet weak var imgObese: UIImageView?
    
    //CLASS VARIABLES
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeUI()
        // Do any additional setup after loading the view.
    }
    
    override func customizeUI() {
        let _height = "Weight / Height (in ^{2})".superscripted()
        lblHeight?.text = _height
        lblBmiTitle?.text = "bmi.title".localize()
        lblClassify?.text = "bmi.sub_title".localize()
        lblUnderweight?.text = "bmi.underweight".localize()
        lblHealthy?.text = "bmi.healthy_weight".localize()
        lblObese?.text = "bmi.obese".localize()
        lblOverweight?.text = "bmi.overweight".localize()
        
        imgUnderweight?.image = UIImage.fontAwesomeIcon(name: .heart,
                                                        style: .solid,
                                                        textColor: .white,
                                                        size: CGSize(width: 30, height: 30))
        
        imgHealthy?.image = UIImage.fontAwesomeIcon(name: .heart,
                                                        style: .solid,
                                                        textColor: .green,
                                                        size: CGSize(width: 30, height: 30))
        
        
        imgOverweight?.image = UIImage.fontAwesomeIcon(name: .heart,
                                                        style: .solid,
                                                        textColor: .yellow,
                                                        size: CGSize(width: 30, height: 30))
        
        imgObese?.image = UIImage.fontAwesomeIcon(name: .heart,
                                                        style: .solid,
                                                        textColor: .red,
                                                        size: CGSize(width: 30, height: 30))
        
        lblBmiTitle?.adjustContentFontSize()
        lblWeight?.adjustContentFontSize()
        lblHeight?.adjustContentFontSize()
        lblClassify?.adjustContentFontSize()
        lblUnderweight?.adjustContentFontSize()
        lblHealthy?.adjustContentFontSize()
        lblObese?.adjustContentFontSize()
        lblOverweight?.adjustContentFontSize()
    }

}

extension BMIInfoController: PanModalPresentable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(180)
    }

    var anchorModalToLongForm: Bool {
        return false
    }
}
