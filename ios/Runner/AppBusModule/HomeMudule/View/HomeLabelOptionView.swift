//
//  HomeLabelOptionView.swift
//  AIRun
//
//  Created by Bolo on 2025/1/20.
//

import UIKit

/// 标签选项
class HomeLabelOptionView: BaseView {
    
    var labsFilterHandle: (() -> Void)?
    private var dataArray: [HomeTagListModel] = []

    override func createUI() {
        addSubview(collectionView)
        addSubview(pullBtn)
    }
    
    override func createUILimit() {
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.height.equalTo(26)
            make.top.equalToSuperview()
            make.trailing.equalTo(-35)
        }
        
        pullBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-16)
            make.size.equalTo(CGSize(width: 13, height: 8))
        }
    }
    
    override func addEvent() {
        
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.showsHorizontalScrollIndicator = false
        cv.register(HomeTagsCollectionViewCell.self, forCellWithReuseIdentifier: HomeTagsCollectionViewCell.description())
        return cv
    }()
    
    lazy var pullBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_home_tag_more"), for: .normal)
    }
}

extension HomeLabelOptionView {
    func showData(_ list: [HomeTagListModel]) {
        self.dataArray.removeAll()
        let all = HomeTagListModel(id: 0, name: "All", sort: 0, is_filter: 0)
        self.dataArray.append(all)
        
        // -若未开启未过滤开关，则默认为全部过滤标签；若已开启未过滤开关，则默认为全部过滤+未过滤标签
        printLog(message: "过滤开关 == \(UserDefaults.userUnfilteredStatus)")
        let tempArr = UserDefaults.userUnfilteredStatus ? list : list.filter({ $0.is_filter == 1 })
        self.dataArray.append(contentsOf: tempArr)
        self.collectionView.reloadData()
    }
    
    func popFilterUpdateSource() {
        self.collectionView.reloadData()
    }
}

extension HomeLabelOptionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTagsCollectionViewCell.description(), for: indexPath) as! HomeTagsCollectionViewCell
        cell.loadData(model: dataArray[indexPath.row])
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let model = dataArray[indexPath.row]
        let size = model.name.textSizeIn(size: CGSize(width: CGFLOAT_MAX, height: 26), font: .mediumFont(size: 15), lineSpace: 0, breakMode: .byWordWrapping, alignment: .center)
        
        return CGSize(width: size.width+24, height: 26)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        
        if model.id == 0 {
            AppCacheManager.default.homeFilter.selectedTags = [0]
            collectionView.reloadData()
            self.labsFilterHandle?()
            return
        }
        
        if let _ = AppCacheManager.default.homeFilter.selectedTags.remove(0) {
            let firstIndex = IndexPath(row: 0, section: 0)
            collectionView.reloadItems(at: [firstIndex])
        }
        
        let seleted = AppCacheManager.default.homeFilter.selectedTags.contains(model.id)
        if seleted {
            AppCacheManager.default.homeFilter.selectedTags.remove(model.id)
        }else {
            if AppCacheManager.default.homeFilter.selectedTags.count >= 5 {
                self.showErrorTipMsg(msg: "Please select up to 5 tags")
                return
            }
            
            AppCacheManager.default.homeFilter.selectedTags.insert(model.id)
        }
        
        collectionView.reloadItems(at: [indexPath])
        self.labsFilterHandle?()
    }

}
