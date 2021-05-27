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
    func setEmptyMessage(message: String, subtitle: String, navigationController: UINavigationController) {
        //print(subviews[0].frame.minX)
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)) //UIView(frame: cloudAppSplitViewController.viewControllers.first!.view.frame)
        let messageLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.text = message
            label.textColor = .label
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .rounded(ofSize: 30, weight: .bold)//UIFont( .boldSystemFont(ofSize: 25)
            return label
        }()

        let subtitleLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.text = subtitle
            label.textColor = .tertiaryLabel
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .rounded(ofSize: 13, weight: .regular)//.boldSystemFont(ofSize: 10) // 20
            return label
        }()

        backgroundView = backView

        backView.addSubview(messageLabel)
        backView.addSubview(subtitleLabel)

        messageLabel.snp.makeConstraints { make in
            make.centerX.equalTo(backView.snp.centerX)
            make.centerY.equalTo(backView.snp.centerY)
            make.leading.equalTo(backView.snp.leading).offset(16 + -(navigationController.view.frame.minX))
            make.trailing.equalTo(backView.snp.trailing).offset(-16)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(backView.snp.centerX)
            make.top.equalTo(messageLabel.snp.bottom)
            make.leading.equalTo(backView.snp.leading).offset(16 + -(navigationController.view.frame.minX))
            make.trailing.equalTo(backView.snp.trailing).offset(-16)
        }

        separatorStyle = .none
    }

    func restore() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}
