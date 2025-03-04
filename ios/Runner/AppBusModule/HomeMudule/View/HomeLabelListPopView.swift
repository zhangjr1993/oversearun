//
//  HomeLabelListPopView.swift
//  AIRun
//
//  Created by Bolo on 2025/1/20.
//

import UIKit

class HomeLabelListPopView: BasePopView {
    
    var popFilterTagsHandle: ((_ tags: Set<Int>) -> Void)?
    private let bag: DisposeBag = DisposeBag()
    private var dataSource: [HomeTagListModel] = []
    private var selectedTags: Set<Int> = [0]

    init(_ list: [HomeTagListModel]) {
        super.init()
        let all = HomeTagListModel(id: 0, name: "All", sort: 0, is_filter: 0)
        self.dataSource.append(all)
        let tempArr = UserDefaults.userUnfilteredStatus ? list : list.filter({ $0.is_filter == 1 })
        self.dataSource.append(contentsOf: tempArr)

        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var hideBtn = UIButton().then {
        $0.backgroundColor = .clear
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
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .appBgColor()
    }
    
    private lazy var titleLab = UILabel().then {
        $0.text = "Tags"
        $0.font = .blackFont(size: 18)
        $0.textColor = .white
    }
    
    private lazy var pullBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_home_pull"), for: .normal)
    }
}

extension HomeLabelListPopView {
    private func labsFitSize() -> CGFloat {
        var rect = CGRect(x: 16, y: 0, width: 0, height: 28)
        for model in  self.dataSource {
            let textSize = model.name.textSizeIn(size: CGSize(width: CGFLOAT_MAX, height: 28), font: UIFont.regularFont(size: 14), lineSpace: 0, breakMode: .byWordWrapping, alignment: .center)
            rect.size = CGSize(width: textSize.width+16, height: 28)

            if rect.origin.x + rect.size.width > UIScreen.screenWidth - 32 {
                rect.origin = CGPoint(x: 16, y: CGRectGetMaxY(rect)+6)
            }
            rect.origin.x = CGRectGetMaxX(rect) + 6
            
            if rect.origin.y >= UIScreen.screenHeight/2.0 {
                break
            }
        }
        return min(CGRectGetMaxY(rect), UIScreen.screenHeight/2.0)
    }
    
    private func createUI() {
        selectedTags = AppCacheManager.default.homeFilter.selectedTags
        self.bgColor = .clear
        
        self.addSubview(hideBtn)
        self.addSubview(containerView)
        containerView.addSubview(titleLab)
        containerView.addSubview(pullBtn)
        containerView.addSubview(collectionView)
    }
    
    private func createUILimit() {
        let collectionHeight = self.labsFitSize() + 48
        
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
        }
        hideBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(UIScreen.statusBarHeight+96)
            make.height.equalTo(collectionHeight)
        }
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(8)
        }
        pullBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.centerY.equalTo(titleLab.snp.centerY)
            make.size.equalTo(CGSize(width: 13, height: 8))
        }
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(titleLab.snp.bottom).offset(6)
            make.bottom.equalTo(-16)
        }
        
    }
    
    private func addEvent() {
        hideBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.saveCureentSeleted()
        }).disposed(by: bag)
        
        pullBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.saveCureentSeleted()
        }).disposed(by: bag)
    }
    
    private func saveCureentSeleted() {
        self.popFilterTagsHandle?(self.selectedTags)
        self.hide()
    }
}

extension HomeLabelListPopView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTagsPopCollectionViewCell.description(), for: indexPath) as! HomeTagsPopCollectionViewCell
        cell.loadData(model: dataSource[indexPath.row], popSeletced: self.selectedTags)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let model = dataSource[indexPath.row]
        let size = model.name.textSizeIn(size: CGSize(width: CGFLOAT_MAX, height: 28), font: .regularFont(size: 14), lineSpace: 0, breakMode: .byWordWrapping, alignment: .center)
        
        return CGSize(width: size.width+16, height: 28)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]

        if model.id == 0 {
            self.selectedTags = [0]
            collectionView.reloadData()
            return
        }
        
        if let _ = self.selectedTags.remove(0) {
            let firstIndex = IndexPath(row: 0, section: 0)
            UIView.performWithoutAnimation {
                collectionView.reloadItems(at: [firstIndex])
            }
        }
        
        let seleted = self.selectedTags.contains(model.id)
        if seleted {
            self.selectedTags.remove(model.id)
        }else {
            if self.selectedTags.count >= 5 {
                self.showErrorTipMsg(msg: "Please select up to 5 tags")
                return
            }
            
            self.selectedTags.insert(model.id)
        }
        
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}
