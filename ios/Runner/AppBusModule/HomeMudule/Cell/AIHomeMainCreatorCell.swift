//
//  AIHomeMainCreatorCell.swift
//  AIRun
//
//  Created by Bolo on 2025/1/23.
//

import UIKit

class AIHomeMainCreatorCell: UITableViewCell {
    
    var didClickCreatorAIHandle: ((Int) -> Void)?
    let cellWidth: CGFloat = (UIScreen.screenWidth-28-42-21)/4
    private var creatorModel = CreatorMainModel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.init(hexStr: "#292929")
    }
    
    private lazy var nickLab = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .white
    }
    
    private lazy var logView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "icon_aihome_creator")
    }
   
    private lazy var headImgView = UIImageView().then {
        $0.layer.cornerRadius = 18
        $0.layer.masksToBounds = true
    }
    
    private lazy var iconView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "btn_aihome_card_more")
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 7
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth+6+15)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.showsHorizontalScrollIndicator = false
        cv.register(HomeCreatorAIListCell.self, forCellWithReuseIdentifier: HomeCreatorAIListCell.description())
        return cv
    }()
}


extension AIHomeMainCreatorCell {
    func configer(model: CreatorMainModel) {
        creatorModel = model
        headImgView.loadNetImage(url: model.headPic, cropType: .equalProportion)
        nickLab.text = model.nickname
        collectionView.reloadData()
        
        collectionView.isHidden = creatorModel.characters.count == 0
        let top: CGFloat = collectionView.isHidden ? 0 : 10
        let height: CGFloat = collectionView.isHidden ? 0 : cellWidth+6+15
        collectionView.snp.remakeConstraints { make in
            make.leading.equalTo(headImgView.snp.leading)
            make.trailing.equalTo(-26)
            make.top.equalTo(headImgView.snp.bottom).offset(top)
            make.height.equalTo(height)
            make.bottom.equalTo(-12)
        }
        
        if collectionView.isHidden {
            iconView.snp.remakeConstraints { make in
                make.trailing.equalTo(-12)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 6, height: 9))
            }
        }else {
            iconView.snp.remakeConstraints { make in
                make.trailing.equalTo(-12)
                make.top.equalTo(collectionView.snp.top).offset(UIScreen.adaptWidth(31))
                make.size.equalTo(CGSize(width: 6, height: 9))
            }
        }
    }
}


extension AIHomeMainCreatorCell {
    private func createUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(headImgView)
        containerView.addSubview(nickLab)
        containerView.addSubview(logView)
        containerView.addSubview(collectionView)
        containerView.addSubview(iconView)
    }
    
    private func createUILimit() {
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(12)
            make.bottom.equalToSuperview()
        }
        headImgView.snp.makeConstraints { make in
            make.leading.top.equalTo(12)
            make.width.height.equalTo(36)
        }
        nickLab.snp.makeConstraints { make in
            make.leading.equalTo(headImgView.snp.trailing).offset(8)
            make.width.lessThanOrEqualTo(UIScreen.screenWidth-165)
            make.centerY.equalTo(headImgView.snp.centerY)
        }
        logView.snp.makeConstraints { make in
            make.leading.equalTo(nickLab.snp.trailing).offset(4)
            make.centerY.equalTo(headImgView.snp.centerY)
            make.size.equalTo(CGSize(width: 61, height: 18))
        }
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(headImgView.snp.leading)
            make.trailing.equalTo(-26)
            make.top.equalTo(headImgView.snp.bottom).offset(10)
            make.height.equalTo(cellWidth+6+15)
            make.bottom.equalTo(-12)
        }
        
    }
    
    private func addEvent() {
        
    }
}

extension AIHomeMainCreatorCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return creatorModel.characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCreatorAIListCell.description(), for: indexPath) as! HomeCreatorAIListCell
        let itemModel = creatorModel.characters[indexPath.row]
        cell.headImgView.loadNetImage(url: itemModel.headPic, cropType: .equalProportion)
        cell.nickLab.text = itemModel.nickname
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemModel = creatorModel.characters[indexPath.row]
        self.didClickCreatorAIHandle?(itemModel.mid)
    }
}


// MARK: - AI
class HomeCreatorAIListCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(headImgView)
        contentView.addSubview(nickLab)
        
        headImgView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(nickLab.snp.top).offset(-6)
        }
        nickLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(1)
            make.height.equalTo(15)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var headImgView = UIImageView().then {
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    lazy var nickLab = UILabel().then {
        $0.textAlignment = .center
        $0.font = .regularFont(size: 14)
        $0.textColor = .whiteColor(alpha: 0.87)
    }
}
