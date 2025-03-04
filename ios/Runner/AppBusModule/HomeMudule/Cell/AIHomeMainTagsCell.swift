//
//  AIHomeMainTagsCell.swift
//  AIRun
//
//  Created by Bolo on 2025/1/23.
//

import UIKit

class AIHomeMainTagsCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var tagsView = HomeCommonTagsView().then {
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
    }
    
    public func showTagsData(_ list: [String]) {
        tagsView.configure(tags: list, type: .aiHome)
    }
}

extension AIHomeMainTagsCell {
    private func createUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        contentView.addSubview(tagsView)
    }
    
    private func createUILimit() {
        tagsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(12)
            make.height.equalTo(24)
            make.bottom.equalToSuperview()
        }
    }
   
}


class AIHomeMainProfileCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear

        contentView.addSubview(ttLab)
        ttLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(12)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var ttLab = UILabel().then {
        $0.font = .regularFont(size: 15)
        $0.textColor = .whiteColor(alpha: 0.87)
        $0.numberOfLines = 0
    }
}
