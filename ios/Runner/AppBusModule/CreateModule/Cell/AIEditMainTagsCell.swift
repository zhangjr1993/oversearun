//
//  AIEditMainTagsCell.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

class AIEditMainTagsCell: AIEditMainCell {
    
    private var dataSource: [HomeTagListModel] = []
    private let configList: [HomeTagListModel] = APPManager.default.config.tagList
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    /// 最多可填10个标签；若用户选择分级为过滤，则无法选择未过滤标签
    /// Unable to select unfiltered label under filter category
    override func loadEditCellModel(_ model: AIEditingMainModel) {
        super.loadEditCellModel(model)
        
        let h: CGFloat
        if model.tags.count == 0 {
            h = 28
            dataSource = []
        }else {
            let result = configList.filter({ model.tags.contains($0.id) })
            dataSource = result
            let fitH = self.labsFitSize()
            h = fitH
        }
        containerView.isHidden = dataSource.count == 0
        addBtn.isHidden = dataSource.count > 0
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(h)
        }
        collectionView.reloadData()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    private lazy var iconView = UIImageView().then {
        $0.image = UIImage.imgNamed(name: "btn_aihome_card_more")
//            .imageWithColor(color: UIColor.init(hexStr: "#999999"))
    }
    
    private lazy var addBtn = LayoutButton().then {
        $0.midSpacing = 8
        $0.imageSize = CGSize(width: 23, height: 23)
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.layer.cornerRadius = 8
        $0.setImage(UIImage.imgNamed(name: "btn_create_add_tag"), for: .normal)
        $0.setTitle("Add Tag", for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.6), for: .normal)
        $0.backgroundColor = UIColor.whiteColor(alpha: 0.05)
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = TagLabelsCollectionViewFlowLayout()
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 6
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.semanticContentAttribute = .forceLeftToRight
        cv.contentInsetAdjustmentBehavior = .never
        cv.register(HomeTagsPopCollectionViewCell.self, forCellWithReuseIdentifier: HomeTagsPopCollectionViewCell.description())
        return cv
    }()
    
    private lazy var containerView = UIButton().then {
        $0.isHidden = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.whiteColor(alpha: 0.05)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(addMoreTags))
        $0.addGestureRecognizer(tap)
    }
    
}

extension AIEditMainTagsCell {
    private func labsFitSize() -> CGFloat {
        var rect = CGRect(x: 16, y: 0, width: 0, height: 28)
        for model in  self.dataSource {
            let textSize = model.name.textSizeIn(size: CGSize(width: CGFLOAT_MAX, height: 28), font: UIFont.regularFont(size: 14), lineSpace: 0, breakMode: .byWordWrapping, alignment: .center)
            rect.size = CGSize(width: textSize.width+16, height: 28)

            if rect.origin.x + rect.size.width > UIScreen.screenWidth - 74 {
                rect.origin = CGPoint(x: 16, y: CGRectGetMaxY(rect)+6)
            }
            rect.origin.x = CGRectGetMaxX(rect) + 6
        }
        return CGRectGetMaxY(rect)
    }
}

extension AIEditMainTagsCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTagsPopCollectionViewCell.description(), for: indexPath) as! HomeTagsPopCollectionViewCell
        cell.showLightData(model: dataSource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let model = dataSource[indexPath.row]
        let size = model.name.textSizeIn(size: CGSize(width: CGFLOAT_MAX, height: 28), font: .regularFont(size: 14), lineSpace: 0, breakMode: .byWordWrapping, alignment: .center)
        
        return CGSize(width: size.width+16, height: 28)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension AIEditMainTagsCell {
    private func createUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(collectionView)
        contentView.addSubview(addBtn)
    }
    
    private func createUILimit() {
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(ttLab.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        iconView.snp.makeConstraints { make in
            make.trailing.equalTo(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 6, height: 9))
        }
        collectionView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(12)
            make.height.equalTo(28)
            make.trailing.equalTo(iconView.snp.leading).offset(-12)
        }
        addBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(containerView.snp.top)
            make.size.equalTo(CGSize(width: 113, height: 47))
        }
    }
    
    private func addEvent() {
        addBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.onChangeSelectedTags(cell: self)
        }).disposed(by: bag)
    }
    
    @objc private func addMoreTags() {
        self.delegate?.onChangeSelectedTags(cell: self)
    }
}
