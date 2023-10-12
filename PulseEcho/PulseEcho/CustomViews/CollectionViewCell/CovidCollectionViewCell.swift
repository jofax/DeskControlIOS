//
//  CovidCollectionViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-06-17.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

protocol CovidCollectionViewCellDelegate {
    func submitCovidAnswers()
}

class CovidCollectionViewCell: SurveyCollectionViewCell {
    
    @IBOutlet weak var iconImage: UIImageView?
    @IBOutlet weak var lblQuestion: UILabel?
    @IBOutlet weak var lblQuestionDetails: VerticalAlignLabel?
    @IBOutlet weak var btnSubmit: UIButton?
    
    var covidCellDelegate: CovidCollectionViewCellDelegate?
    var covidTotalQuestions: Int = -1
    
    var covidDetails: SurveyQuestions? {
        didSet {
            guard let item = covidDetails else {
                return
            }
            iconImage?.image = UIImage(named: item.ImageURL)
            lblQuestion?.text = item.Text
            //createSurveyOptions(options: item.ScaleOptions)
            let _details: [String] = item.Details.map { $0.content }
            lblQuestionDetails?.attributedText = BulletedList.createBulletedList(fromStringArray:_details, font: UIFont(name: Constants.smartpods_font_gotham, size: 16.0))
            lblQuestionDetails?.verticalAlignment = .top
            btnSubmit?.isHidden = !(index == (covidTotalQuestions - 1))
            btnSubmit?.isEnabled = (index == (covidTotalQuestions - 1))
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction override func onBtnActions(sender: UIButton) {
        covidCellDelegate?.submitCovidAnswers()
    }

}

