//
//  AIEditMainTableFooterView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

class AIEditMainTableFooterView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var checkBtn = UIButton().then {
        $0.isSelected = true
        $0.setImage(UIImage.imgNamed(name: "btn_create_unchecked"), for: .normal)
        $0.setImage(UIImage.imgNamed(name: "btn_create_check_ok"), for: .selected)
    }
    
    lazy var desLab = UILabel().then {
        $0.text = "I confirm my character does not infringe on the image,intellectual property, or any other rights."
        $0.numberOfLines = 0
        $0.textColor = .whiteColor(alpha: 0.6)
        $0.font = .mediumFont(size: 13)
    }
}

extension AIEditMainTableFooterView {
    private func createUI() {
        self.addSubview(checkBtn)
        self.addSubview(desLab)
    }
    
    private func createUILimit() {
        checkBtn.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(27)
            make.width.height.equalTo(13)
        }
        desLab.snp.makeConstraints { make in
            make.leading.equalTo(checkBtn.snp.trailing).offset(8)
            make.trailing.equalTo(-16)
            make.top.equalTo(checkBtn.snp.top).offset(-2)
        }
    }
    
    func addSharke() {
        
    }
}
