//
//  HomeListContainerController.swift
//  AIRun
//
//  Created by Bolo on 2025/1/20.
//

import UIKit

class HomeListContainerController: BaseViewController {
    
    /// 记录页面上一次显示时同步的AppCacheManager
    private var lastTags: Set<Int> = [0]
    /// 上一次性别筛选条件
    private var lastSex: UserSexType = .unowned
    private var dataArray: [HomeCommonListModel] = []
    private var tabModel = HomeTabListModel()
    private var page = 1
    
    init(tabModel: HomeTabListModel, sex: UserSexType, tags: Set<Int>) {
        super.init(nibName: nil, bundle: nil)
        self.tabModel = tabModel
        self.lastSex = sex
        self.lastTags = tags
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createUI()
        self.createUILimit()
        self.addEvent()
        self.beginRefresh()
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

    public func synchronizeFilterTags() {
        let tags = AppCacheManager.default.homeFilter.selectedTags
        let sex = AppCacheManager.default.homeFilter.sex
        
        if lastTags != tags || lastSex != sex {
            self.lastSex = sex
            self.lastTags = tags
            self.beginRefresh()
        }
        
    }
}

extension HomeListContainerController {
    private func createUI() {
        self.hideNaviBar = true
        self.view.addSubview(collectionView)
    }
    
    private func createUILimit() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addEvent() {
        collectionView.addMJRefreshHeader { [weak self] in
            guard let `self` = self else { return }
            self.beginRefresh()
        }
        
        collectionView.addMJBackStateFooter { [weak self] in
            guard let `self` = self else { return }
            self.getHomeListData()
        }
        
        /// 关注
        NotificationCenter.default.rx.notification(.aiAttentionUpdated).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            guard let obj = noti.object as? [String: Any],
                    let mid = obj["mid"] as? Int,
                  let status = obj["status"] as? Bool,
                  let tabId = obj["tab"] as? Int else { return }
            guard let index = self.dataArray.firstIndex(where: { $0.mid == mid }) else { return }
            self.dataArray[index].isAttention = status
            
            if tabId == self.tabModel.tab {
                return
            }
            
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }).disposed(by: bag)
        
        /// 删除
        NotificationCenter.default.rx.notification(.aiDeletedUpdated).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            guard let obj = noti.object as? [String: Any], let mid = obj["mid"] as? Int else { return }
            guard let index = self.dataArray.firstIndex(where: { $0.mid == mid }) else { return }
            self.dataArray.remove(at: index)
            self.collectionView.reloadData()
        }).disposed(by: bag)
        
        /// 拉黑
        NotificationCenter.default.rx.notification(.aiBlockedUpdated).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            guard let obj = noti.object as? [String: Any], let mid = obj["mid"] as? Int else { return }
            guard let index = self.dataArray.firstIndex(where: { $0.mid == mid }) else { return }
            self.dataArray.remove(at: index)
            self.collectionView.reloadData()
        }).disposed(by: bag)
    }
    
    private func beginRefresh() {
        self.page = 1
        self.getHomeListData()
    }
}

extension HomeListContainerController {
    
    
    private func getHomeListData() {

        let tags = Array(self.lastTags).filter { tag in tag != 0 } // All 的时候不要传0
        let tagsStr = tags.map(String.init).joined(separator: ",")
        
        let params: [String: Any] = ["page": self.page,
                                     "tab": self.tabModel.tab,
                                     "sex": self.lastSex.rawValue,
                                     "is_filter": UserDefaults.userUnfilteredStatus ? 0 : 1,
                                     "tags": tagsStr]
        
        AppRequest(HomeModuleApi.homeList(params: params), modelType: TransferHomeCommonListModel.self) { [weak self] listModel, model in
            guard let `self` = self else { return }
            if self.page == 1 {
                self.dataArray.removeAll()
                self.collectionView.endRefresh()
            }
            self.collectionView.endNextLoadMoreData(next: listModel.hasNext)
            
            var dealList = listModel.list
            dealList.indices.forEach { index in
                dealList[index].calculateHeight()
                printLog(message: dealList[index].itemHeight)
            }
            
            self.page += 1
            self.dataArray.append(contentsOf: dealList)
            self.collectionView.backgroundView?.isHidden = self.dataArray.count > 0
            self.collectionView.reloadData()
        } errorBlock: { [weak self] code, msg in
            guard let `self` = self else { return }
            self.collectionView.endRefresh()
        }
    }
}

extension HomeListContainerController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension HomeListContainerController: WaterfallsCollectionViewLayoutDelegate {
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

extension HomeListContainerController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCommonListCell.description(), for: indexPath) as! HomeCommonListCell
        cell.showDataModel(dataArray[indexPath.row], isFollow: false, tabId: self.tabModel.tab)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        APPPushManager.default.pushAIHomePage(mid: model.mid, isPresent: true)
    }
}


