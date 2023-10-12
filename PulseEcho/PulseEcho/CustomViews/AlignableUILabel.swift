//
//  AlignableUILabel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-11.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class UIAlignedLabel: UILabel {

    override func drawText(in rect: CGRect) {
        if let text = text as NSString? {
            func defaultRect(for maxSize: CGSize) -> CGRect {
                let size = text
                    .boundingRect(
                        with: maxSize,
                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                        attributes: [
                            NSAttributedString.Key.font: font ?? UIFont.systemFontSize
                        ],
                        context: nil
                    ).size
                let rect = CGRect(
                    origin: .zero,
                    size: CGSize(
                        width: min(frame.width, ceil(size.width)),
                        height: min(frame.height, ceil(size.height))
                    )
                )
                return rect

            }
            switch contentMode {
            case .top, .bottom, .left, .right, .topLeft, .topRight, .bottomLeft, .bottomRight:
                let maxSize = CGSize(width: frame.width, height: frame.height)
                var rect = defaultRect(for: maxSize)
                switch contentMode {
                    case .bottom, .bottomLeft, .bottomRight:
                        rect.origin.y = frame.height - rect.height
                    default: break
                }
                switch contentMode {
                    case .right, .topRight, .bottomRight:
                        rect.origin.x = frame.width - rect.width
                    default: break
                }
                super.drawText(in: rect)
            default:
                super.drawText(in: rect)
            }
        } else {
            super.drawText(in: rect)
        }
    }

}
