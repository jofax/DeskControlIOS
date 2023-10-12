//
//  SurveyCollectionViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-17.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import TGPControls

protocol SurveyCollectionViewCellDelegate: class {
    func addAnswer(index: Int, question: SurveyQuestions)
}

class SurveyCollectionViewCell: BaseCollectionViewCell {
    @IBOutlet weak var txtSurveyQuestion: UITextView?
    @IBOutlet weak var lblDisagree: UILabel?
    @IBOutlet weak var lblRangeValue: UILabel?
    @IBOutlet weak var lblAgree: UILabel?
    @IBOutlet weak var btnMinus: UIButton?
    @IBOutlet weak var answerSlider: TGPDiscreteSlider?
    @IBOutlet weak var lblComments: UILabel?
    @IBOutlet weak var txtComments: UITextView?
    @IBOutlet weak var btnBack: CustomButtonWithShadow?
    
    @IBOutlet weak var btnNext: CustomButtonWithShadow?
    @IBOutlet weak var btnPlus: UIButton?
    @IBOutlet weak var stackSurveyOptions: UIStackView?
    
    weak var delegate: SurveyCollectionViewCellDelegate?
    var index: Int = 0
    
    var surveyQuestions: SurveyQuestions? {
        didSet {
            guard let item = surveyQuestions else {
                return
            }
            txtSurveyQuestion?.text = item.Text
            createSurveyOptions(options: item.ScaleOptions)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnBack?.isHidden = false
        txtSurveyQuestion?.adjustContentFontSize()
        lblDisagree?.adjustContentFontSize()
        lblRangeValue?.adjustNumberFontSize()
        lblAgree?.adjustContentFontSize()
        lblComments?.adjustContentFontSize()
        txtComments?.adjustContentFontSize()
        btnBack?.titleLabel?.adjustContentFontSize()
        btnNext?.titleLabel?.adjustContentFontSize()
        //answerSlider?.addTarget(self, action: #selector(self.sliderValueChange), for: .valueChanged)
        
        btnBack?.isHidden = true
        
    }
    
    
    
    @objc func sliderValueChange(_ sender: TGPDiscreteSlider, event:UIEvent) {
        self.answer(value: sender.value)
    }
    
    func answer(value: CGFloat) {
        lblRangeValue?.text = String(format:"%.0f", value)
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        switch sender.tag {
            case 0:
                break
            case 1:
                break
            case 2:
                if Int(answerSlider?.value ?? 0) > 0 {
                    answerSlider?.value -= 1
                    answer(value: answerSlider?.value ?? 0)
                }
            case 3:
                if Int(answerSlider?.value ?? 0) < 10 {
                    answerSlider?.value += 1
                    answer(value: answerSlider?.value ?? 0)
                }
            default: break
        }
    }
    
   @objc func addAnswer(sender: UIButton) {
        resetButtonAnswers()
        sender.isSelected = !sender.isSelected
        print("AMSWER TAG: ", sender.tag)
        self.surveyQuestions?.SelectedAnswer = sender.tag
        delegate?.addAnswer(index: self.index, question: self.surveyQuestions ?? SurveyQuestions(params: [String:Any]()))
    }
    
    func resetButtonAnswers() {
        let buttons = stackSurveyOptions?.allSubviews.compactMap { $0 as? UIButton }
        if let _buttons = buttons {
            for item in _buttons {
                item.isSelected = false
            }
        }
    }
    
    func createSurveyOptions(options: [SurveyScaleOptions]) {
        stackSurveyOptions?.removeAllArrangedSubviews()
        switch deviceSize {
            case .i6_1Inch, .i6_5Inch, .i5_8Inch, .i5_5Inch:
            //stackSurveyOptions?.spacing = 30
                break
            default:
                
                //stackSurveyOptions?.spacing = 20
                break
        }
        
        for (index,item) in options.enumerated() {
            
            let answer = CustomButtonWithShadow(type: .custom)
            answer.translatesAutoresizingMaskIntoConstraints = false
            
            if deviceSize == .i4Inch {
                let heightConstraint = answer.heightAnchor.constraint(equalToConstant: 30)
                answer.addConstraints([heightConstraint])
            } else {
                let heightConstraint = answer.heightAnchor.constraint(equalToConstant: 50)
                answer.addConstraints([heightConstraint])
            }
            
           
            
            answer.tag = item.ID
            answer.isSelected = (item.ID == self.surveyQuestions?.SelectedAnswer) ? true : false
            answer.titleLabel?.font = UIFont(name: Constants.smartpods_font_gotham, size: 16.0)
            answer.setTitle(item.Text, for: .normal)
            
            answer.titleLabel?.minimumScaleFactor = 0.5
            answer.titleLabel?.adjustsFontSizeToFitWidth = true
            
            answer.addTarget(self, action: #selector(addAnswer(sender:)), for: .touchUpInside)
            answer.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
            answer.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
            answer.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
            answer.titleLabel?.adjustContentFontSize()
            stackSurveyOptions?.insertArrangedSubview(answer, at: index)
        }
    }

}

