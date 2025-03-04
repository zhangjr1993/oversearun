//
//  NetTipView.swift
//  AIRun
//
//  Created by AIRun on 2024/3/14.
//

import UIKit

class NetTipView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSubviews()
        self.setupViewsConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var tipLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .regularFont(size: 13)
        lab.text = "No network currently, Please check your network"
        lab.textAlignment = .center
        return lab
    }()
}

extension NetTipView {
    private func createSubviews() {
        self.backgroundColor = .appRedColor()
        self.addSubview(tipLab)
    }
    
    private func setupViewsConstraint() {
        tipLab.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
