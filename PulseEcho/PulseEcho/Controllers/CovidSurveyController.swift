//
//  CovidSurveyController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-06-16.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift

//Question tag
// 3 = YES
// 4 = NO

typealias COVID_QUESTIONS_DONE = () -> Void
typealias COVID_SCREEN = () -> Void

protocol CovidSurveyControllerDelegate {
    func didAnswerAllQuestions()
}

class CovidSurveyController: SurveyController {
    var dataViewModel: SurveyViewModel = SurveyViewModel(type: .isCovid)
    @IBOutlet weak var btnCanadaTelNumber: UIButton?
    @IBOutlet weak var btnCoronaTelNumber: UIButton?
    
    @IBOutlet weak var btnPrevQuestion: UIButton?
    @IBOutlet weak var btnNextQuestion: UIButton?
    
    @IBOutlet weak var btnYes: UIButton?
    @IBOutlet weak var btnNo: UIButton?
    
    @IBOutlet var btnIndicator: [UIButton]!
    @IBOutlet weak var btnSubmit: UIButton?
    
    var covidAnswers = [[String: Any]]()
    
    var delegate: CovidSurveyControllerDelegate?
    var covidQuestionDone: COVID_QUESTIONS_DONE?
    
    var assessment: Any? {
        didSet {
            refreshList()
        }
    }
    
    var totalCovidQuestions:Int = 0
    var currentQuestionIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeUI()
        refreshList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       refreshList()
    }
    
    override func customizeUI() {
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = dataViewModel
        self.collectionView?.isUserInteractionEnabled = true
        
        btnCanadaTelNumber?.underline()
        btnCoronaTelNumber?.underline()
        
        collectionView?.collectionViewLayout = collectionLayout
        
        lblQuestionsCount?.adjustContentFontSize()
        
        btnPrevQuestion?.setImage(UIImage.fontAwesomeIcon(name: .chevronLeft,
                                                    style: .solid,
                                                    textColor: UIColor(hexString: Constants.smartpods_blue),
                                                    size: CGSize(width: 50, height: 50)), for: .normal)
        
        btnNextQuestion?.setImage(UIImage.fontAwesomeIcon(name: .chevronRight,
                                                    style: .solid,
                                                    textColor: UIColor(hexString: Constants.smartpods_blue),
                                                    size: CGSize(width: 50, height: 50)), for: .normal)
        
        btnNextQuestion?.titleLabel?.adjustContentFontSize()
        
        btnYes?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnYes?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        btnNo?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnNo?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        btnSubmit?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnSubmit?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        self.collectionView?.register(CovidCollectionViewCell.nib, forCellWithReuseIdentifier: CovidCollectionViewCell.identifier)
    }
    
    func refreshList() {
        guard assessment != nil else {
            view.emptyState.hide()
            return
        }
        
        if assessment is Survey {
            self.enableSurveryControls(enable: false)
            let _survey = assessment as! Survey
            totalCovidQuestions = _survey.Questions.count
            self.dataViewModel.survey = Survey(survey: _survey)
            self.dataViewModel.refreshSurveyData(_survey)
            self.dataViewModel.type = .isCovid
            self.collectionView?.reloadData()
            view.emptyState.hide()
            updateQuestionCount(index: self.collectionLayout.indexOfMajorCell())
            pageIndicator(index: self.collectionLayout.indexOfMajorCell())
            answerIndicator(index: self.collectionLayout.indexOfMajorCell())
        }
    }
    
    override func getSurvey() {
        
    }
    
    override func bindViewModelAndCallbacks() {
        self.dataViewModel.successResponse = { [weak self] (object: Any) in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction override func onBtnActions(sender: UIButton) {
        switch sender.tag {
            case 0:
                guard let dataSourceCount = collectionView?.dataSource?.collectionView(collectionView ?? UICollectionView(), numberOfItemsInSection: 0),
                             dataSourceCount > 0 else {
                                 return
                      }
                 
                        let indexOfMajorCell = self.collectionLayout.indexOfMajorCell()
                        let hasEnoughVelocityToSlideToThePreviousCell = indexOfMajorCell - 1 != 0
                       
                       
                    guard hasEnoughVelocityToSlideToThePreviousCell else {
                        collectionView?.scrollToItem(
                                           at: IndexPath(row: 0, section: 0),
                                           at: self.collectionLayout.centerPosition ? .centeredHorizontally : .left, // TODO: Left ignores inset
                                           animated: true
                                       )
                                       self.currentQuestionIndex = 0
                                       self.updateQuestionCount(index: 0)
                                       self.answerIndicator(index: 0)
                                       self.pageIndicator(index: 0)
                        
                        return
                    }
                    
                    collectionView?.scrollToItem(
                        at: IndexPath(row: indexOfMajorCell - 1, section: 0),
                        at: self.collectionLayout.centerPosition ? .centeredHorizontally : .left, // TODO: Left ignores inset
                        animated: true
                    )
                    self.currentQuestionIndex = indexOfMajorCell - 1
                    self.updateQuestionCount(index: indexOfMajorCell - 1)
                    self.pageIndicator(index: indexOfMajorCell - 1)
                    self.answerIndicator(index: indexOfMajorCell - 1)
            case 1:
                guard let dataSourceCount = collectionView?.dataSource?.collectionView(collectionView ?? UICollectionView(), numberOfItemsInSection: 0),
                             dataSourceCount > 0 else {
                                 return
                      }
                 
                        let indexOfMajorCell = self.collectionLayout.indexOfMajorCell()
                        let velocity = CGPoint(x: self.collectionView?.frame.width ?? 0, y: 0)
                        let swipeVelocityThreshold: CGFloat = 0.5 // After some trail and error
                        let hasEnoughVelocityToSlideToTheNextCell = self.collectionLayout.indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
                       
                       
                    guard hasEnoughVelocityToSlideToTheNextCell && (indexOfMajorCell + 1) < totalCovidQuestions else {
                        return
                    }
                    self.updateQuestionCount(index: indexOfMajorCell + 1)
                    self.answerIndicator(index: indexOfMajorCell + 1)
                    self.currentQuestionIndex = indexOfMajorCell + 1
                    self.pageIndicator(index: indexOfMajorCell + 1)
                    collectionView?.scrollToItem(
                        at: IndexPath(row: indexOfMajorCell + 1, section: 0),
                        at: self.collectionLayout.centerPosition ? .centeredHorizontally : .left, // TODO: Left ignores inset
                        animated: true
                    )
                
        case 2:
            break
        case 3:
            resetAnswers()
            self.saveAnswer(tag: sender.tag, index: self.currentQuestionIndex)
        case 4:
            resetAnswers()
            self.saveAnswer(tag: sender.tag, index: self.currentQuestionIndex)
            break
        case 9, 10:
            self.callNumber(phoneNumber: sender.titleLabel?.text ?? "")
            break
        case 11:
            
            let answers = self.dataViewModel.survey?.Questions.filter({ (question) -> Bool in
                return question.SelectedAnswer != -1
            })
            
            let totalAnswers = answers?.count ?? 0
            
            
            guard totalAnswers > 0 && (totalAnswers == totalCovidQuestions) else {
                let _title = "generic.error_title".localize()
                let _message = "covid.not_enough_answers_message".localize()
                
                self.showAlertFromController(controller: self, title: _title, message: _message)
                return
            }
            
            self.dismiss(animated: true, completion: {
                self.covidQuestionDone?()
            })
            break
        default:
            break
        }
    }
    
   override func updateQuestionCount(index: Int) {
        self.currentQuestionIndex = index

        btnPrevQuestion?.isHidden = (index == 0) ? true : false
         
        if index == totalCovidQuestions - 1 {
            btnNextQuestion?.tag = 2
            
            btnNextQuestion?.setImage(nil, for: .normal)
            btnNextQuestion?.isHidden = true
            btnNextQuestion?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
            btnNextQuestion?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
            
        } else {
            btnNextQuestion?.isHidden = false
            btnNextQuestion?.tag = 1
            btnNextQuestion?.setTitle(nil, for: .normal)
            btnNextQuestion?.setBackgroundColor(color: .clear, forState: .normal)
            btnNextQuestion?.setBackgroundColor(color: .clear, forState: .highlighted)
            btnNextQuestion?.setImage(UIImage.fontAwesomeIcon(name: .chevronRight,
                                                      style: .solid,
                                                      textColor: UIColor(hexString: Constants.smartpods_blue),
                                                      size: CGSize(width: 50, height: 50)), for: .normal)
        }
    }
    
    func answerIndicator(index: Int) {
        resetAnswers()
        guard self.dataViewModel.survey != nil else {
          return
        }

        let questions = self.dataViewModel.survey?.Questions

        guard questions?.count ?? 0 > 0 else {
          return
        }

        let question = questions?[index]
        
        if question?.SelectedAnswer == 3 {
            btnYes?.isSelected = true
            btnNo?.isSelected = false
        } else if (question?.SelectedAnswer == 4) {
            btnYes?.isSelected = false
            btnNo?.isSelected = true
        } else {
            resetAnswers()
        }
        
        let answers = self.dataViewModel.survey?.Questions.filter({ (question) -> Bool in
            return question.SelectedAnswer != -1
        })
        
        let totalAnswers = answers?.count
        
        if totalAnswers == totalCovidQuestions {
            btnSubmit?.isHidden = false
            btnSubmit?.isEnabled =  true
            return

        }
        
        btnSubmit?.isHidden = !(index == (totalCovidQuestions - 1))
        btnSubmit?.isEnabled = (index == (totalCovidQuestions - 1))

    }
    
    func pageIndicator(index: Int) {
        
        for btn in btnIndicator {
            btn.isSelected = false
        }
        
        btnIndicator[index].isSelected = true
    }
    
    func resetAnswers() {
        btnYes?.isSelected = false
        btnNo?.isSelected = false
    }
    
    func saveAnswer(tag: Int, index: Int) {
        
        if tag == 3 {
            btnYes?.isSelected = true
            btnNo?.isSelected = false
        } else {
            btnYes?.isSelected = false
            btnNo?.isSelected = true
        }
        
        var updatedQuestion: SurveyQuestions = SurveyQuestions(object: self.dataViewModel.survey?.Questions[index] ?? SurveyQuestions(params: ["":""]))
        updatedQuestion.SelectedAnswer = tag
        self.dataViewModel.updateSurveyAnswer(index: index, question: updatedQuestion)
        
        
    }
}

extension CovidSurveyController {

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        guard let layout = collectionView?.collectionViewLayout as? SnapPagingLayout else { return }
        layout.willBeginDragging()
        self.updateQuestionCount(index: self.collectionLayout.indexOfMajorCell())
        pageIndicator(index: self.collectionLayout.indexOfMajorCell())
        answerIndicator(index: self.collectionLayout.indexOfMajorCell())
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = collectionView?.collectionViewLayout as? SnapPagingLayout else { return }
        layout.willEndDragging(withVelocity: velocity, targetContentOffset: targetContentOffset)
        self.updateQuestionCount(index: self.collectionLayout.indexOfMajorCell())
        pageIndicator(index: self.collectionLayout.indexOfMajorCell())
        answerIndicator(index: self.collectionLayout.indexOfMajorCell())
    }
    
}
