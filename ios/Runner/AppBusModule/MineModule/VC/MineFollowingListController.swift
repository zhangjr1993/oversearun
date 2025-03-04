//
//  MineFollowingListController.swift
//  AIRun
//
//  Created by Bolo on 2025/2/6.
//

import UIKit

class MineFollowingListController: BaseViewController {

    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    
    private var dataArray: [HomeCommonListModel] = []
    private var page = 1

    deinit {
        listViewDidScrollCallback = nil
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

}

extension MineFollowingListController {
    private func loadFollowingListData() {
        AppRequest(MineModuleApi.followingList(params: ["page": self.page]), modelType: TransferHomeCommonListModel.self) { [weak self] listModel, model in
            guard let `self` = self else { return }
            if self.page == 1 {
                self.dataArray.removeAll()
                self.collectionView.endRefresh()
            }else {
                self.collectionView.endLoadMoreData(count: listModel.list.count)
            }
            var dealList = listModel.list
            dealList.indices.forEach { index in
                dealList[index].calculateHeight()
                printLog(message: dealList[index].itemHeight)
            }
            
            self.page += 1
            self.dataArray.append(contentsOf: dealList)
            self.collectionView.backgroundView?.isHidden = self.dataArray.count > 0
            self.collectionView.reloadData()
        }errorBlock: { [weak self] code, msg in
            self?.collectionView.endRefresh()
        }
    }
    
    
}

extension MineFollowingListController {
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
            self.loadFollowingListData()
        }
        
        /// 关注
        NotificationCenter.default.rx.notification(.aiAttentionUpdated).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            guard let obj = noti.object as? [String: Any],
                    let mid = obj["mid"] as? Int,
                    let status = obj["status"] as? Bool else { return }
            if status == true {
                self.beginRefresh()
                return
            }
            guard let index = self.dataArray.firstIndex(where: { $0.mid == mid }), status == false else { return }
            self.updateUI(index: index)
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
        self.loadFollowingListData()
    }
}

extension MineFollowingListController: WaterfallsCollectionViewLayoutDelegate {
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

extension MineFollowingListController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCommonListCell.description(), for: indexPath) as! HomeCommonListCell
        cell.showDataModel(dataArray[indexPath.row], isFollow: true, tabId: 10000)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        APPPushManager.default.pushAIHomePage(mid: model.mid, isPresent: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.listViewDidScrollCallback?(scrollView)
    }
}


extension MineFollowingListController: JXPagingViewListViewDelegate {
    public func listView() -> UIView {
        return self.view
    }
    
    public func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }

    public func listScrollView() -> UIScrollView {
        return self.collectionView
    }
}
