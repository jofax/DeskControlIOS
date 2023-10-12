//
//  SummaryTableViewHeader.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-27.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

protocol SummaryTableViewHeaderDelegte {
    func headerShowReportDetails(_ section: Int, _ item: [String: Any])
}

class SummaryTableViewHeader: BaseTableHeader {
    
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblValue: UILabel?
    @IBOutlet weak var stackView: UIStackView?
    var delegate:SummaryTableViewHeaderDelegte?
    
    var section: Int = 0
    var sectionTitle = [String: Any]()
    var item: Statistics? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle?.adjustContentFontSize()
        lblValue?.adjustContentFontSize()
        let detailstTap = UITapGestureRecognizer(target: self, action: #selector(showReportDetails(_:)))
        detailstTap.numberOfTapsRequired = 1
        self.stackView?.addGestureRecognizer(detailstTap)
    }
    
    @objc func showReportDetails(_ sender: UITapGestureRecognizer) {
        delegate?.headerShowReportDetails(section, sectionTitle)
    }
    
    func updateUI() {
        guard let report = item else {
            return
        }
        
        if (sectionTitle["title"] != nil) {
            let _title = sectionTitle["title"] as? String ?? ""
            let _key = sectionTitle["key"] as? String ?? ""
            lblTitle?.text = _title
            
            if _key == "UpDownPerHour" {
                lblValue?.text = String(format: "%.2f", report.UpDownPerHour)
            }
            
            if _key == "TotalActivity" {
                lblValue?.text = String(format: "%.0f %%", report.TotalActivity)
            }
        }
    }
}
