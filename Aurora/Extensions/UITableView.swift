//
// Aurora
// File created by Lea Baumgart on 29.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import Foundation
import UIKit

extension UITableView {
    func setEmptyMessage(message: String, subtitle: String) {
        let backView = UIView(frame: cloudAppSplitViewController.viewControllers.first!.view.frame) // UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        let messageLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.text = message
            label.textColor = .label
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 25)
            return label
        }()

        let subtitleLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.text = subtitle
            label.textColor = .tertiaryLabel
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 10) // 20
            return label
        }()

        backgroundView = backView

        backView.addSubview(messageLabel)
        backView.addSubview(subtitleLabel)

        messageLabel.snp.makeConstraints { make in
            make.centerX.equalTo(backView.snp.centerX)
            make.centerY.equalTo(backView.snp.centerY)
            make.leading.equalTo(backView.snp.leading).offset(16)
            make.trailing.equalTo(backView.snp.trailing).offset(-16)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(backView.snp.centerX)
            make.top.equalTo(messageLabel.snp.bottom)
            make.leading.equalTo(backView.snp.leading).offset(16)
            make.trailing.equalTo(backView.snp.trailing).offset(-16)
        }

        separatorStyle = .none
    }

    func restore() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}
