//
//  HomeViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-09.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class HomeViewModel: BaseViewModel {
    var menu = [[String: String]]()
    
    override init() {
        super.init()
        self.menu = Constants.smartpods_menu
    }
    
}

extension HomeViewModel:  UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionViewCell.identifier, for: indexPath) as! MenuCollectionViewCell
        cell.menu = menu[indexPath.row]
        return cell
    }
}

extension HomeViewModel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

extension HomeViewModel: UICollectionViewDelegate {
    
}
