//
//  ManTopNavigation.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-15.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import SnapKit

protocol MainTopNavigationDelegate {
    func backToPreviewsView()
    func backToHomeView()
}

class MainTopNavigation: UIView {
    
    //CLASS DELEGATE
    public var delegate: MainTopNavigationDelegate?
    
    //UI DECLARATIONS
    lazy var homeButton: UIButton = {
        let homeBtn = UIButton(type: .custom)
        homeBtn.translatesAutoresizingMaskIntoConstraints = false
        homeBtn.setImage(UIImage(named: "home_btn"), for: .normal)
        homeBtn.setImage(UIImage(named: "home_btn_selected"), for: .highlighted)
        homeBtn.imageView?.contentMode = .scaleAspectFit
        return homeBtn
    }()
    
    lazy var backButton: UIButton = {
        let backBtn = UIButton(type: .custom)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.setImage(UIImage(named: "back_click"), for: .highlighted)
        backBtn.imageView?.contentMode = .scaleToFill
        backBtn.frame.origin.x = 0
        return backBtn
    }()
    
    lazy var stack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.yellow
        self.createNavigationButtons()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createNavigationButtons()
    }
    
    /**
    Create navigation buttons.
    - Parameters none
    - Returns: none
    */
    
    private func createNavigationButtons() {
        //self.stack.addArrangedSubview(self.backButton)
        //self.stack.addArrangedSubview(UIButton())
        //self.addSubview(self.stack)
        self.addSubview(self.backButton)
        addViewConstraints()
        addButtonActions()
    }
    
    /**
    Add view constraints in this view.
    - Parameters none
    - Returns: none
    */
    
    private func addViewConstraints() {
//        stack.backgroundColor = .red
//        stack.snp.makeConstraints { (make) -> Void in
//           make.width.height.equalTo(self)
//           make.center.equalTo(self)
//        }
        
        backButton.snp.makeConstraints { (make) -> Void in
           make.width.height.equalTo(self)
           //make.center.equalTo(self)
            make.leading.equalTo(self)
        }
    }
    
    /**
    Add button actions.
    - Parameters none
    - Returns: none
    */
    
    func addButtonActions() {
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        homeButton.addTarget(self, action: #selector(homeButtonPressed), for: .touchUpInside)
    }
    
    /**
    Back button pressed. Call delegate method backToPreviewsView()
    - Parameters none
    - Returns: none
    */
    
    @objc private func backButtonPressed() {
        delegate?.backToPreviewsView()
    }
    
    /**
    Home button pressed. Call delegate method backToHomeView()
    - Parameters none
    - Returns: none
    */
    
    @objc private func homeButtonPressed() {
        delegate?.backToHomeView()
    }
    
    
//    override var intrinsicContentSize: CGSize {
//      //preferred content size, calculate it if some internal state changes
//      return CGSize(width: 200, height: 60)
//    }
    
    override class var requiresConstraintBasedLayout: Bool {
      return true
    }
}
