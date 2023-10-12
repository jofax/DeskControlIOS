//
//  DeskStatisticsViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-20.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class DeskStatisticsViewModel: BaseViewModel {
    var statistics = Constants.desk_statistics
    var setPageNumber: ((_ page: Int) -> Void)?
}

extension DeskStatisticsViewModel:  UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statistics.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = statistics[indexPath.row]
        let type = Int(data["type"] ?? "0")
        
        if type == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeskDefaultCollectionViewCell.identifier, for: indexPath) as! DeskDefaultCollectionViewCell
            cell.object = data
            return cell
        } else if type == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeskUtilizationCollectionViewCell.identifier, for: indexPath) as! DeskUtilizationCollectionViewCell
            cell.object = data
            return cell
            
        } else if type == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeskTypeUsersCollectionViewCell.identifier, for: indexPath) as! DeskTypeUsersCollectionViewCell
            cell.object = data
            return cell
        } else if type == 3 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeskLifeCycleCollectionViewCell.identifier, for: indexPath) as! DeskLifeCycleCollectionViewCell
            cell.object = data
            return cell
        } else if (type == 4 || type == 5 || type == 6) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeskTempCollectionViewCell.identifier, for: indexPath) as! DeskTempCollectionViewCell
            cell.object = data
            return cell
        } else {
            return UICollectionViewCell()
        }
        
        
        
    }
}

/*extension DeskStatisticsViewModel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.bounds.width
        return CGSize(width: collectionViewWidth/2, height: collectionViewWidth/2)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}*/

extension DeskStatisticsViewModel: UICollectionViewDelegate, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let horizontalCenter = width / 2
        setPageNumber?(Int(offSet + horizontalCenter) / Int(width))
    }
}
