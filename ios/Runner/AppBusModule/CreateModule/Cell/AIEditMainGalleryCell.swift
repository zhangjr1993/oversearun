//
//  AIEditMainGalleryCell.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

class AIEditMainGalleryCell: AIEditMainCell {
    
    let cellWidth: CGFloat = (UIScreen.screenWidth-32-16)/3
    var dataArray: [AIEditingGalleryModel] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    override func loadEditCellModel(_ model: AIEditingMainModel) {
        super.loadEditCellModel(model)
        self.collectionView.isHidden = model.photoAssets.count == 0
        self.addBtn.isHidden = model.photoAssets.count != 0
        var h: CGFloat = 0
        if model.photoAssets.count == 0 {
            h = 73
        }else if model.photoAssets.count > 0, model.photoAssets.count < 3 {
            h = 109
        }else if model.photoAssets.count >= 3, model.photoAssets.count < 6 {
            h =  109*2+8
        }else {
            h = 109*3+8*2
        }
        self.collectionView.snp.updateConstraints { make in
            make.height.equalTo(h)
        }
        self.dataArray = model.photoAssets
        self.collectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        let collect = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collect.isHidden = true
        collect.delegate = self
        collect.dataSource = self
        collect.backgroundColor = .clear
        collect.isScrollEnabled = false
        collect.register(AIEditMainGalleryCollectionCell.self, forCellWithReuseIdentifier: AIEditMainGalleryCollectionCell.description())
        collect.register(AIEditMainAddGalleryCollectionCell.self, forCellWithReuseIdentifier: AIEditMainAddGalleryCollectionCell.description())
        return collect
    }()
    
    private lazy var addBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_newai_upload_pic"), for: .normal)
        $0.backgroundColor = UIColor.whiteColor(alpha: 0.05)
        $0.layer.cornerRadius = 8
    }
}

extension AIEditMainGalleryCell {
    private func deleteCellPic(indexPath: IndexPath?) {
        guard let indexPath else { return }
        dataArray.remove(at: dataArray.count < 9 ? indexPath.row - 1 : indexPath.row)
        self.delegate?.onChangeGalleryPic(cell: self, last: dataArray, isDelete: true)
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
    }
}

extension AIEditMainGalleryCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count < 9 ? dataArray.count + 1 : dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if dataArray.count < 9, indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIEditMainAddGalleryCollectionCell.description(), for: indexPath) as! AIEditMainAddGalleryCollectionCell
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIEditMainGalleryCollectionCell.description(), for: indexPath) as! AIEditMainGalleryCollectionCell
            let row = dataArray.count < 9 ? indexPath.row - 1 : indexPath.row
            let model = dataArray[row]
            if model.photoAsset?.isNetworkAsset ?? false {
                cell.picView.loadNetImage(url: model.url, cropType: .equalProportion)
            }else {
                cell.picView.image = model.photoAsset?.originalImage?.cropMaxEdgeImage()
            }
            cell.didCellDeletePicHandle = { [weak self] cellIndex in
                guard let `self` = self else { return }
                self.deleteCellPic(indexPath: cellIndex)
            }
            cell.indexPath = indexPath
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dataArray.count < 9, indexPath.row == 0 {
            self.delegate?.onChangeGalleryPic(cell: self, last: self.dataArray, isDelete: false)
        }
    }
}

extension AIEditMainGalleryCell {
    
    private func createUI() {
        contentView.addSubview(addBtn)
        contentView.addSubview(collectionView)
    }
    
    private func createUILimit() {
        addBtn.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(ttLab.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 109, height: 73))
        }
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(addBtn.snp.top)
            make.height.equalTo(73)
            make.bottom.equalToSuperview()
        }
    }
    
    private func addEvent() {
        addBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.onChangeGalleryPic(cell: self, last: self.dataArray, isDelete: false)
        }).disposed(by: bag)
    }
}


// MARK: - 相册cell
class AIEditMainGalleryCollectionCell: UICollectionViewCell {
    
    var didCellDeletePicHandle: ((_ indexPath: IndexPath?) -> Void)?
    var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(picView)
        contentView.addSubview(deleteBtn)
        
        picView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        deleteBtn.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var picView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private lazy var deleteBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_create_pictures_delete"), for: .normal)
        $0.addTarget(self, action: #selector(clickDeleteBtn), for: .touchUpInside)
    }
    
    @objc private func clickDeleteBtn() {
        self.didCellDeletePicHandle?(self.indexPath)
    }
}

class AIEditMainAddGalleryCollectionCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(addBtn)
        
        addBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private lazy var addBtn = UIButton().then {
        $0.isUserInteractionEnabled = false
        $0.setImage(UIImage.imgNamed(name: "btn_newai_upload_pic"), for: .normal)
        $0.backgroundColor = .whiteColor(alpha: 0.05)
        $0.layer.cornerRadius = 8
    }
}
