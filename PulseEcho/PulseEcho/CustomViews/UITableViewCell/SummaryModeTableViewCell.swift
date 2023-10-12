//
//  SummaryTableViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-27.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class SummaryModeTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    var section: Int = 0
    var report = [String: Any]()
    var dataList =  [Any]()
    var item: Statistics? {
       didSet {
           updateUI()
       }
    }
       
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView?.register(PercentageCollectionViewCell.nib, forCellWithReuseIdentifier: PercentageCollectionViewCell.identifier)
        // Initialization code
    }
    
    override func prepareForReuse() {
         super.prepareForReuse()
        dataList.removeAll()
        self.collectionView?.reloadData()
    }
    
    func updateUI() {
          guard let _statistics = item else {
              return
          }
         
        if (report["key"] != nil) {
                let _key = report["key"] as? String ?? ""

                switch _key {
                    case "ModePercentage":
                        let items = [["title":"Semi Automatic", "value":_statistics.ModePercentage.SemiAutomatic],
                                     ["title":"Automatic", "value":_statistics.ModePercentage.Automatic],
                                     ["title":"Manual", "value":_statistics.ModePercentage.Manual]]
                        dataList = items

                        break
                    case "ActivityByDesk":
                        //dataList.append(contentsOf: _statistics.ActivityByDesk)
                        dataList = _statistics.ActivityByDesk
                        break
                    default:
                        break
                }

            self.collectionView?.reloadData()

        }
        
      }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SummaryModeTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PercentageCollectionViewCell.identifier, for: indexPath) as! PercentageCollectionViewCell
        cell.report = report
        
        let _key = report["key"] as? String ?? ""

        switch _key {
            case "ModePercentage":
                cell.object = dataList[indexPath.row] as? [String: Any]
            case "ActivityByDesk":
                cell.activity = dataList[indexPath.row] as? DeskActivities
            default:
                break
        }
        
        
        return cell
    }
    
    
}

extension SummaryModeTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension SummaryModeTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 100)
    }
}
