//
//  ScrollViewStack.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-02.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit

/// Scrollview that contains a stackview to simple scrollable content.
public class ScrollViewStack: UIScrollView {
    
    /// StackView's spacing property.
    public var spacing: CGFloat {
        get {
            return stackView.spacing
        } set {
            stackView.spacing = newValue
        }
    }
    
    /// StackView's distribution property.
    public var distribution: UIStackView.Distribution {
        get {
            return stackView.distribution
        } set {
            stackView.distribution = newValue
        }
    }
    
    /// StackView's alignment property.
    public var alignment: UIStackView.Alignment {
        get {
            return stackView.alignment
        } set {
            stackView.alignment = newValue
        }
    }
    
    /// Updated the axis of the stack view and it's constraints.
    public var axis: NSLayoutConstraint.Axis = .vertical {
        didSet {
            setupConstaints(axis: axis)
        }
    }
    
    /// Enables the keyboard notifications for updating the content inset of the scrollview.
    public var enableKeyboardNotifications = false {
        didSet {
            if enableKeyboardNotifications && enableKeyboardNotifications != oldValue {
                observeKeyboardAppearance()
            } else {
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    /// Default bottom inset used to handle keyboard notifications.
    public var defaultBottomInset: CGFloat = 0
    
    /// Stack view that contains all of the views.
    fileprivate let stackView = UIStackView()
    
    fileprivate var sizeConstraint: NSLayoutConstraint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStackView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Inserts a new view below the content already inside of the stack view.
    ///
    /// - Parameter view: Used to insert below the current content on the stack view.
    /// - Parameter height: Used to constraint the height of the view.
    /// - Parameter width: Used to constraint the width of the view.
    public func insertView(view: UIView, height: CGFloat? = nil, width: CGFloat? = nil) {
        stackView.insertArrangedSubview(view, at: stackView.arrangedSubviews.count)

        if let height = height {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let width = width {
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    
    /// Inserts an empty view to act as a divider.
    ///
    /// - Parameter height: Height of the divider view used if the axis is vertical.
    /// - Parameter width: Width of the divider view used if the axis is horizontal.
    public func insertDividerView(height: CGFloat? = nil,
                                  width: CGFloat? = nil,
                                  backgroundColor: UIColor = UIColor.clear) {
        
        let dividerView = UIView()
        dividerView.backgroundColor = backgroundColor
        insertView(view: dividerView, height: height, width: width)
    }
    
    /// Clear all the arranged views.
    public func clearViews() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}

// MARK:- Keyboard Functions

extension ScrollViewStack {
    
    /// Increases the scrollview's bottom content inset to allow the keyboard to show.
    ///
    /// - Parameter notification: Notification used to grab the keyboard height.
    @objc public func onKeyboardShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        extendLayout(bottomInset: keyboardSize.height)
    }
    
    /// Resets the scrollview's bottom inset to the default inset.
    ///
    /// - Parameter _: Notification unused.
    @objc public func onKeyboardDismiss(notification: NSNotification) {
        extendLayout(bottomInset: defaultBottomInset)
    }
    
    private func extendLayout(bottomInset: CGFloat) {
        var adjustContentInsets = contentInset
        var adjustScrollIndicatorInsets = scrollIndicatorInsets
        
        adjustContentInsets.bottom = bottomInset
        adjustScrollIndicatorInsets.bottom = bottomInset
        
        contentInset = adjustContentInsets
        scrollIndicatorInsets = adjustScrollIndicatorInsets
    }
}

// MARK:- Private Functions

private extension ScrollViewStack {
    
    func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fill

        setupConstraints()
    }
    
    func setupConstaints(axis: NSLayoutConstraint.Axis) {
        stackView.axis = axis
        sizeConstraint?.isActive = false
        
        if axis == .vertical {
            sizeConstraint = stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
        } else {
            sizeConstraint = stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1)
        }
        
        sizeConstraint?.isActive = true
    }
    
    func observeKeyboardAppearance() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardDismiss(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func setupConstraints() {
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        setupConstaints(axis: axis)
    }
}
