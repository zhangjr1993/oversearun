//
//  ChatTableFooterView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/14.
//

import UIKit
import NVActivityIndicatorView

class ChatTableFooterView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        effectView.stopAnimating()
    }
    
    lazy var headPicView: UIImageView = {
        let imgV = UIImageView()
        imgV.layer.cornerRadius = 17
        imgV.layer.masksToBounds = true
        return imgV
    }()
    
    lazy var nickLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .regularFont(size: 15)
        return lab
    }()
    
    lazy var bubbleImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleToFill
        imgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return imgView
    }()
    
    lazy var effectView: NVActivityIndicatorView = {
        let v = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: UIColor.appBrownColor(0.5), padding: 0)
        return v
    }()
}

extension ChatTableFooterView {
    func loadInfoData(model: ChatInfoDataModel) {
        nickLab.text = model.nickname
        headPicView.loadNetImage(url: model.headPic)
    }
}

extension ChatTableFooterView {
    private func createUI() {
        addSubview(headPicView)
        addSubview(nickLab)
        addSubview(bubbleImgView)
        bubbleImgView.addSubview(effectView)
    }
    
    private func createUILimit() {
        headPicView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(12)
            make.width.height.equalTo(34)
        }
        nickLab.snp.makeConstraints { make in
            make.top.equalTo(headPicView)
            make.leading.equalTo(58)
        }
        bubbleImgView.snp.makeConstraints { make in
            make.leading.equalTo(58)
            make.top.equalTo(nickLab.snp.bottom).offset(6)
            make.size.equalTo(CGSize(width: 68, height: 39))
        }
        effectView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 20))
        }
    }
    
    private func addEvent() {
        let imag = UIImage.imgNamed(name: "img_chat_other")
        let sizex = imag.size
        bubbleImgView.image = imag.resizableImage(withCapInsets: UIEdgeInsets(top: sizex.height*0.5, left: sizex.width*0.5, bottom: sizex.height*0.5, right: sizex.width*0.5), resizingMode: .stretch)
        effectView.startAnimating()
    }
}
