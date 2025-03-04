//
//  MsgTimeTableCell.swift
//  AIRun
//
//  Created by AIRun on 20247/20.
//

import UIKit

class MsgTimeTableCell: MsgBaseTableCell {

    var timeCellData: MsgTimeCellData?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func createSubviews() {
        super.createSubviews()
        self.bubbleImgView.isHidden = true
        self.containerView.isHidden = true
        self.headPicView.isHidden = true
        self.nickLab.isHidden = true

        self.contentView.addSubview(msgLabel)
        msgLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(25)
            make.top.bottom.equalToSuperview().inset(10)
            make.center.equalToSuperview()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    override func fillWithData(data: MsgBaseCellData, chatInfo: ChatInfoDataModel) {
        super.fillWithData(data: data, chatInfo: chatInfo)
        self.timeCellData = data as? MsgTimeCellData
        self.msgLabel.text = self.timeCellData?.contentStr
    }
    
    lazy var msgLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.appTitle1Color()
        lab.font = .regularFont(size: 14)
        lab.numberOfLines = 0
        lab.textAlignment = .center
        return lab
    }()
}

class MsgTimeCellData: MsgBaseCellData {
    
    var contentStr = ""
    
}
