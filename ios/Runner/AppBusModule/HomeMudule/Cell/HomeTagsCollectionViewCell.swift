//
//  HomeTagsCollectionViewCell.swift
//  AIRun
//
//  Created by Bolo on 2025/1/20.
//

import UIKit

class HomeTagsCollectionViewCell: UICollectionViewCell {
    
    private let lightImage = UIImage.createGradientImg(colors: UIColor.appGradientColor(), size: CGSize(width: 200, height: 28))
    private let norImage = UIImage.createColorImg(color: UIColor.whiteColor(alpha: 0.05))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var ttLab = UILabel().then {
        $0.textColor = UIColor.whiteColor(alpha: 0.38)
        $0.font = .mediumFont(size: 15)
    }
    
    private lazy var bgImgView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 14
        $0.image = norImage
    }
}

extension HomeTagsCollectionViewCell {
    func loadData(model: HomeTagListModel) {

        let selected: Bool = AppCacheManager.default.homeFilter.selectedTags.contains(model.id)
        bgImgView.image = selected ? lightImage : norImage
        
        let matchStr = model.is_filter == 2 ? "(Unfiltered)" : ""
        let textColor = selected ? UIColor.appBrownColor() : UIColor.whiteColor(alpha: 0.38)
        let matchColor = selected ? UIColor.appBrownColor() : UIColor.appPinkColor()
        let attributed = model.name.matchAttributedStr(textColor, .mediumFont(size: 15), matchColor, .mediumFont(size: 15), matchStr)
        ttLab.attributedText = attributed
        
    }
}

extension HomeTagsCollectionViewCell {
    private func createUI() {
        contentView.addSubview(bgImgView)
        contentView.addSubview(ttLab)
    }
    
    private func createUILimit() {
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        ttLab.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}

// MARK: -----------------------------------
class HomeTagsPopCollectionViewCell: UICollectionViewCell {
    
    private let lightImage = UIImage.createGradientImg(colors: UIColor.appGradientColor(), size: CGSize(width: 200, height: 28))
    private let norImage = UIImage.createColorImg(color: UIColor.whiteColor(alpha: 0.1))
    private let otherNorImage = UIImage.createColorImg(color: UIColor.init(hexStr: "#333333"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
        self.createUILimit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var ttLab = UILabel().then {
        $0.textColor = UIColor.white
        $0.font = .regularFont(size: 14)
    }
    
    private lazy var bgImgView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 14
        $0.image = norImage
    }
}

extension HomeTagsPopCollectionViewCell {
    /// 首页
    func loadData(model: HomeTagListModel, popSeletced: Set<Int>) {

        let selected: Bool = popSeletced.contains(model.id)
        bgImgView.image = selected ? lightImage : norImage
        
        let matchStr = model.is_filter == 2 ? "(Unfiltered)" : ""
        let textColor = selected ? UIColor.appBrownColor() : UIColor.whiteColor(alpha: 0.38)
        let matchColor = selected ? UIColor.appBrownColor() : UIColor.appPinkColor()
        let attributed = model.name.matchAttributedStr(textColor, .regularFont(size: 14), matchColor, .regularFont(size: 14), matchStr)
        ttLab.attributedText = attributed
        
    }
    
    /// 编辑AI显示的cell
    func showLightData(model: HomeTagListModel) {
        bgImgView.image = lightImage
        let matchStr = model.is_filter == 2 ? "(Unfiltered)" : ""
        let textColor = UIColor.appBrownColor()
        let matchColor = UIColor.appBrownColor()
        let attributed = model.name.matchAttributedStr(textColor, .regularFont(size: 14), matchColor, .regularFont(size: 14), matchStr)
        ttLab.attributedText = attributed
    }
    
    /// 创建/编辑tag弹窗
    func loadCellDataFromEdit(model: HomeTagListModel, popSeletced: Set<Int>) {
        let selected: Bool = popSeletced.contains(model.id)
        bgImgView.image = selected ? lightImage : otherNorImage
        
        let matchStr = model.is_filter == 2 ? "(Unfiltered)" : ""
        let textColor = selected ? UIColor.appBrownColor() : UIColor.whiteColor(alpha: 0.38)
        let matchColor = selected ? UIColor.appBrownColor() : UIColor.appPinkColor()
        let attributed = model.name.matchAttributedStr(textColor, .regularFont(size: 14), matchColor, .regularFont(size: 14), matchStr)
        ttLab.attributedText = attributed
    }
}

extension HomeTagsPopCollectionViewCell {
    private func createUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(bgImgView)
        contentView.addSubview(ttLab)
    }
    
    private func createUILimit() {
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        ttLab.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
