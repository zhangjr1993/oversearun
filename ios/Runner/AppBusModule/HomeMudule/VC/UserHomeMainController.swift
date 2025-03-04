//
//  UserHomeMainController.swift
//  AIRun
//
//  Created by Bolo on 2025/2/6.
//

import UIKit

// 用户主页
class UserHomeMainController: BaseViewController {

    var userId = 0
    private var dataArray: [HomeCommonListModel] = []
    private var page = 1
    
    init (_ uid: Int) {
        super.init(nibName: nil, bundle: nil)
        self.userId = uid
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createUI()
        self.createUILimit()
        self.addEvent()
        self.beginRefresh()
    }
    
    private lazy var userInfoView = CreatorHomeInfoView().then {
        $0.backgroundColor = .clear
    }

    private lazy var collectionView: UICollectionView = {
        let layout = WaterfallsCollectionViewLayout()
        layout.flowDelegae = self

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.backgroundView = BaseTableView.emptyBackgroundView()
        cv.backgroundView?.isHidden = true
        cv.register(HomeCommonListCell.self, forCellWithReuseIdentifier: HomeCommonListCell.description())
        return cv
    }()
    
}

extension UserHomeMainController {
    private func loadAIListData() {
        let params: [String: Any] = ["uid": self.userId,
                                     "page": self.page]
        
        AppRequest(HomeModuleApi.creatorHomePage(params: params), modelType: CreatorHomeMainModel.self) { [weak self] result, model in
            guard let `self` = self else { return }
            self.dealResponseListData(result: result)
        }errorBlock: { [weak self] code, msg in
            self?.collectionView.endRefresh()
        }
    }
    
    func dealResponseListData(result: CreatorHomeMainModel) {
        if self.page == 1 {
            self.dataArray.removeAll()
            self.collectionView.endRefresh()
        }else {
            self.collectionView.endLoadMoreData(count: result.aiList.count)
        }
        var dealList = result.aiList
        dealList.indices.forEach { index in
            dealList[index].calculateHeight()
            printLog(message: dealList[index].itemHeight)
        }
        self.userInfoView.loadDataModel(result)
        self.page += 1
        self.dataArray.append(contentsOf: dealList)
        self.collectionView.backgroundView?.isHidden = self.dataArray.count > 0
        self.collectionView.reloadData()
    }
}

extension UserHomeMainController {
    private func createUI() {
        self.view.addSubview(collectionView)
        self.view.addSubview(userInfoView)
        
        userInfoView.uid = userId
    }
    
    private func createUILimit() {
        userInfoView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(112)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(userInfoView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    private func addEvent() {
        userInfoView.blockUserHandle = { [weak self] in
            guard let `self` = self else { return }
            self.naviPopback()
        }
        
        collectionView.addMJRefreshHeader { [weak self] in
            guard let `self` = self else { return }
            self.beginRefresh()
        }
        
        collectionView.addMJBackStateFooter { [weak self] in
            guard let `self` = self else { return }
            self.loadAIListData()
        }
        
        /// 关注
        NotificationCenter.default.rx.notification(.aiAttentionUpdated).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            guard let obj = noti.object as? [String: Any],
                    let mid = obj["mid"] as? Int,
                    let status = obj["status"] as? Bool else { return }
            guard let index = self.dataArray.firstIndex(where: { $0.mid == mid }) else { return }
            self.dataArray[index].isAttention = status
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }).disposed(by: bag)
       
        /// 删除
        NotificationCenter.default.rx.notification(.aiDeletedUpdated).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            guard let obj = noti.object as? [String: Any], let mid = obj["mid"] as? Int else { return }
            guard let index = self.dataArray.firstIndex(where: { $0.mid == mid }) else { return }
            self.updateUI(index: index)
        }).disposed(by: bag)
        
        /// 拉黑
        NotificationCenter.default.rx.notification(.aiBlockedUpdated).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            guard let obj = noti.object as? [String: Any],
                    let mid = obj["mid"] as? Int,
                    let status = obj["status"] as? Bool else { return }
            guard let index = self.dataArray.firstIndex(where: { $0.mid == mid }), status == true else { return }
            self.updateUI(index: index)
        }).disposed(by: bag)
    }
    
    private func updateUI(index: Int) {
        self.dataArray.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        self.collectionView.backgroundView?.isHidden = self.dataArray.count > 0
    }
    
    
    private func beginRefresh() {
        self.page = 1
        self.loadAIListData()
    }
}

extension UserHomeMainController: WaterfallsCollectionViewLayoutDelegate {
    func heightForRowAtIndexPath(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        let model = dataArray[indexPath.row]
        return model.itemHeight
    }
    
    func insetForSection(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16)
    }
    
    func lineSpacing(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, section: Int) -> CGFloat {
        return 12.0
    }
    
    func interitemSpacing(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, section: Int) -> CGFloat {
        return 12.0
    }
}

extension UserHomeMainController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCommonListCell.description(), for: indexPath) as! HomeCommonListCell
        cell.showDataModel(dataArray[indexPath.row], isFollow: false, tabId: 10001)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        APPPushManager.default.pushToChatView(aiMID: model.mid)
    }
}
