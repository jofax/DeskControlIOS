//
//  SurveryController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-24.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import SwiftEventBus
import FontAwesome_swift
import EmptyStateKit

class SurveyController: BaseController {
    
    //STORYBOARD OUTLETS
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var viewContainer: UIView?
    @IBOutlet weak var lblQuestionsCount: UILabel?
    @IBOutlet weak var btnNext: UIButton?
    @IBOutlet weak var btnPrevious: UIButton?
    //CLASS VARIABLES
    
    var viewModel: SurveyViewModel =  SurveyViewModel(type: .isSurvey)
    var collectionLayout = SnapPagingLayout(
        centerPosition: true,
        peekWidth: 0,
        spacing: 0,
        inset: 0
    )
    var currentIndex: Int = 0
    var totalQuestions: Int = 0
    var _data: Any? {
        didSet {
            updateUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        SPBluetoothManager.shared.event = self.event
        createCustomNavigationBar(title: "survey.title".localize(), user: email, cloud: true, back: false, ble: true)
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    override func customizeUI() {
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = viewModel
        
        if viewModel.type == .isSurvey {
            view.emptyState.format = DataState.noSurvey.format
            view.emptyState.delegate = self
        }
        
        collectionView?.collectionViewLayout = collectionLayout
        
        lblQuestionsCount?.adjustContentFontSize()
        
        btnPrevious?.setImage(UIImage.fontAwesomeIcon(name: .chevronLeft,
                                                    style: .solid,
                                                    textColor: UIColor(hexString: Constants.smartpods_blue),
                                                    size: CGSize(width: 50, height: 50)), for: .normal)
        
        btnNext?.setImage(UIImage.fontAwesomeIcon(name: .chevronRight,
                                                    style: .solid,
                                                    textColor: UIColor(hexString: Constants.smartpods_blue),
                                                    size: CGSize(width: 50, height: 50)), for: .normal)
        
        btnNext?.titleLabel?.adjustContentFontSize()
        
        self.collectionView?.register(SurveyCollectionViewCell.nib, forCellWithReuseIdentifier: SurveyCollectionViewCell.identifier)
    }
    
    func updateUI() {
        guard _data != nil else {
            getSurvey()
            return
        }
        
        if _data is Survey {
            self.enableSurveryControls(enable: false)
            let _survey = _data as! Survey
            totalQuestions = _survey.Questions.count
            self.viewModel.refreshSurveyData(_survey)
            self.collectionView?.reloadData()
            updateQuestionCount(index: self.collectionLayout.indexOfMajorCell())
        }
    }
    
    func getSurvey() {
        
        guard viewModel.type == .isSurvey else {
            return
        }
        
        app_delegate.getSurvey { (object) in
            if object is Survey {
                self.enableSurveryControls(enable: false)
                self.view.emptyState.hide()
                let _survey = object as! Survey
                self.totalQuestions = _survey.Questions.count
                self.viewModel.refreshSurveyData(_survey)
                self.collectionView?.reloadData()
                self.updateQuestionCount(index: self.collectionLayout.indexOfMajorCell())
            } else {
                self.collectionView?.reloadData()
                self.enableSurveryControls(enable: true)
                self.view.emptyState.show(DataState.noSurvey)
                self.collectionView?.isHidden = true
            }
        }
    }
    
    func enableSurveryControls(enable: Bool) {
        btnPrevious?.isHidden = enable
        btnNext?.isHidden = enable
        lblQuestionsCount?.isHidden = enable
    }
    
    override func bindViewModelAndCallbacks() {
        
        viewModel.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            //self?.displayStatusNotification(title: message, style: .danger)
            if tag == 1 {
                self?.showAlert(title: title, message: message)
            }
        }

        viewModel.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
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
                                   self.updateQuestionCount(index: 0)
                    
                    return
                }
                
                collectionView?.scrollToItem(
                    at: IndexPath(row: indexOfMajorCell - 1, section: 0),
                    at: self.collectionLayout.centerPosition ? .centeredHorizontally : .left, // TODO: Left ignores inset
                    animated: true
                )
                self.updateQuestionCount(index: indexOfMajorCell - 1)
        case 1:
            guard let dataSourceCount = collectionView?.dataSource?.collectionView(collectionView ?? UICollectionView(), numberOfItemsInSection: 0),
                         dataSourceCount > 0 else {
                             return
                  }
             
                    let indexOfMajorCell = self.collectionLayout.indexOfMajorCell()
                    let velocity = CGPoint(x: self.collectionView?.frame.width ?? 0, y: 0)
                    let swipeVelocityThreshold: CGFloat = 0.5 // After some trail and error
                    let hasEnoughVelocityToSlideToTheNextCell = self.collectionLayout.indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
                   
                   
                guard hasEnoughVelocityToSlideToTheNextCell && (indexOfMajorCell + 1) < totalQuestions else {
                    return
                }
                self.updateQuestionCount(index: indexOfMajorCell + 1)
                collectionView?.scrollToItem(
                    at: IndexPath(row: indexOfMajorCell + 1, section: 0),
                    at: self.collectionLayout.centerPosition ? .centeredHorizontally : .left, // TODO: Left ignores inset
                    animated: true
                )
            
        case 2:
            
            guard viewModel.type == .isSurvey else {
                return
            }
            
            viewModel.submitSurveyAnswers { (object) in
                guard object is GenericResponse else {
                    return
                }
                
                let _object = object as! GenericResponse
                var _title: String = ""
                var _message: String = ""
                
                if _object.Success {
                    _title = "success.thanks".localize()
                    _message = "success.survey_success".localize()
                    self.getSurvey()
                    
                } else {
                    _title = "generic.error_title".localize()
                    _message = "generic.other_error".localize()
                }
                
                self.showAlert(title: _title, message: _message)
                
            }
            break
                
        default: break
        }
    }
    
    func updateQuestionCount(index: Int) {
        self.lblQuestionsCount?.text = String(format: "%d / %d", (index + 1), totalQuestions)
        btnPrevious?.isHidden = (index == 0) ? true : false
        
        if index == totalQuestions - 1 {
            btnNext?.tag = 2
            btnNext?.setImage(nil, for: .normal)
            btnNext?.setTitle("    Submit    ", for: .normal)
            btnNext?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
            btnNext?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
            
        } else {
            btnNext?.tag = 1
            btnNext?.setTitle(nil, for: .normal)
            btnNext?.setBackgroundColor(color: .clear, forState: .normal)
            btnNext?.setBackgroundColor(color: .clear, forState: .highlighted)
            btnNext?.setImage(UIImage.fontAwesomeIcon(name: .chevronRight,
                                                      style: .solid,
                                                      textColor: UIColor(hexString: Constants.smartpods_blue),
                                                      size: CGSize(width: 50, height: 50)), for: .normal)
        }
        
    }

}

extension SurveyController: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        guard let layout = collectionView?.collectionViewLayout as? SnapPagingLayout else { return }
        self.updateQuestionCount(index: self.collectionLayout.indexOfMajorCell())
        layout.willBeginDragging()
        
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = collectionView?.collectionViewLayout as? SnapPagingLayout else { return }
        self.updateQuestionCount(index: self.collectionLayout.indexOfMajorCell())
        
        layout.willEndDragging(withVelocity: velocity, targetContentOffset: targetContentOffset)

    }
    
}

extension SurveyController: EmptyStateDelegate {
    
    func emptyState(emptyState: EmptyState, didPressButton button: UIButton) {
        getSurvey()
        view.emptyState.hide()
    }
}
