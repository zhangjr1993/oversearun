//
//  AIEditTagsPopView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/10.
//

import UIKit

class AIEditTagsPopView: BasePopView {

    var saveSelectedTagsHandle: ((_ tags: [Int]) -> Void)?
    var dataTags: [Int] = []
    
    private let bag: DisposeBag = DisposeBag()
    private let dataSource: [HomeTagListModel] = APPManager.default.config.tagList
    private var selectedTags: Set<Int> = []
    private var isFilter = 0
    /// 未过滤标签id
    private var filterIds: [Int] = []

    init(selected: [Int], isFilter: Int) {
        super.init()
        self.isFilter = isFilter
        self.selectedTags = Set(selected)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var closeBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_windows_close"), for: .normal)
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
        $0.backgroundColor = UIColor.init(hexStr: "#242325")
    }
    
    private lazy var titleLab = UILabel().then {
        $0.text = "Tags"
        $0.font = .blackFont(size: 18)
        $0.textColor = .white
    }
    
    private lazy var limitLab = UILabel().then {
        $0.text = "Please select up to 10 tags"
        $0.font = .mediumFont(size: 16)
        $0.textColor = .whiteColor(alpha: 0.87)
    }
    
    private lazy var saveBtn = UIButton().then {
        let img = UIImage.createButtonImage(type: .lightGray, size: CGSize(width: UIScreen.screenWidth-96, height: 48), isCorner: 24)
        let img2 = UIImage.createButtonImage(type: .normal, size: CGSize(width: UIScreen.screenWidth-96, height: 48), isCorner: 24)
        $0.setBackgroundImage(img2, for: .normal)
        $0.setBackgroundImage(img, for: .disabled)
        $0.setTitle("Save", for: .normal)
        $0.setTitle("Save", for: .disabled)
        $0.setTitleColor(UIColor.appBrownColor(), for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.6), for: .disabled)
        $0.isEnabled = false
    }
}

extension AIEditTagsPopView {
   
    private func createUI() {
        self.animationType = .sheet
        self.enableTouchHide = false
        self.filterIds = dataSource.filter({ $0.is_filter == 2 }).map({ $0.id })
        
        self.addSubview(containerView)
        containerView.addSubview(closeBtn)
        containerView.addSubview(titleLab)
        containerView.addSubview(limitLab)
        containerView.addSubview(collectionView)
        containerView.addSubview(saveBtn)
    }
    
    private func createUILimit() {        
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight/2+100))
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(30)
        }
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.centerY.equalTo(titleLab)
            make.width.height.equalTo(24)
        }
        limitLab.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(titleLab.snp.bottom).offset(12)
        }
       
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(limitLab.snp.bottom).offset(12)
            make.bottom.equalTo(saveBtn.snp.top).offset(-12)
        }
        saveBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(48)
            make.height.equalTo(48)
            make.bottom.equalTo(-12-UIScreen.safeAreaInsets.bottom)
        }
        
        self.containerView.clipCorner([.topLeft, .topRight], radius: 16, rect: CGRect(origin: .zero, size: CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight/2+100)))
        
    }
    
    private func addEvent() {
        closeBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }).disposed(by: bag)
        
        saveBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            
            if self.isFilter == 1, self.selectedTags.firstIndex(where: { self.filterIds.contains($0) }) != nil {
                self.showErrorTipMsg(msg: "Unable to select unfiltered label under filter category")
                let tags = self.selectedTags.filter({ self.filterIds.contains($0) == false })
                self.selectedTags = tags
            }
            
            self.saveSelectedTagsHandle?(self.selectedTags.sorted())
            self.hide()
        }).disposed(by: bag)
    }
}

extension AIEditTagsPopView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTagsPopCollectionViewCell.description(), for: indexPath) as! HomeTagsPopCollectionViewCell
        cell.loadCellDataFromEdit(model: dataSource[indexPath.row], popSeletced: self.selectedTags)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let model = dataSource[indexPath.row]
        let size = model.name.textSizeIn(size: CGSize(width: CGFLOAT_MAX, height: 28), font: .regularFont(size: 14), lineSpace: 0, breakMode: .byWordWrapping, alignment: .center)
        
        return CGSize(width: size.width+16, height: 28)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]

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
            if self.selectedTags.count >= 10 {
                self.showErrorTipMsg(msg: "Please select up to 10 tags")
                return
            }
            
            self.selectedTags.insert(model.id)
        }
        
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
        
        
        self.saveBtn.isEnabled = self.selectedTags.count > 0 && self.selectedTags.sorted() != dataTags.sorted()
    }
}
