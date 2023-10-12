//
//  DeskStatisticsController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-26.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift
import Blueprints
import Device

class DeskStatisticsController: BaseController {

    //STORYBOARD OUTLETS
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var pageControl: UIPageControl?
    
    //CLASS VARIABLES
    var viewModel: DeskStatisticsViewModel?

    
    private var indexOfCellBeforeDragging = 0
    
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "desk_statistics.title".localize(), user: email, cloud: true, back: false, ble: true)
        customizeUI()
    }
    
    override func customizeUI() {
        viewModel = DeskStatisticsViewModel()
        
        collectionView?.delegate = viewModel
        collectionView?.dataSource = viewModel
        
        pageControl?.hidesForSinglePage = true
        pageControl?.numberOfPages = (viewModel?.statistics.count ?? 0) / 6
        
        collectionView?.register(DeskUtilizationCollectionViewCell.nib, forCellWithReuseIdentifier: DeskUtilizationCollectionViewCell.identifier)
        collectionView?.register(DeskDefaultCollectionViewCell.nib, forCellWithReuseIdentifier: DeskDefaultCollectionViewCell.identifier)
        collectionView?.register(DeskLifeCycleCollectionViewCell.nib, forCellWithReuseIdentifier: DeskLifeCycleCollectionViewCell.identifier)
        collectionView?.register(DeskTempCollectionViewCell.nib, forCellWithReuseIdentifier: DeskTempCollectionViewCell.identifier)
        collectionView?.register(DeskTypeUsersCollectionViewCell.nib, forCellWithReuseIdentifier: DeskTypeUsersCollectionViewCell.identifier)
        
        let _height: CGFloat = (Device.size() == .screen4_7Inch) ? 130 : 150
        
        let blueprintLayout = HorizontalBlueprintLayout(
          itemsPerRow: 2,
          itemsPerColumn: 3,
          height: _height,
          minimumInteritemSpacing: 5,
          minimumLineSpacing: 5,
          sectionInset: EdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
          stickyHeaders: false,
          stickyFooters: false
        )
        collectionView?.collectionViewLayout = blueprintLayout
        
        bindViewModelAndCallbacks()

    }
    
    
    override func bindViewModelAndCallbacks() {
        
        viewModel?.setPageNumber = { [weak self] (page: Int) in
            self?.pageControl?.currentPage = page
        }
        
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }

        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

}
