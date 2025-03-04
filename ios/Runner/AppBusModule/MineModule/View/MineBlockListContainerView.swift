//
//  MineBlockListContainerView.swift
//  AIRun
//
//  Created by Bolo on 2025/2/6.
//

import UIKit

class MineBlockListContainerView: UIView {
    
    var listViewDidScrollCallback: ((UIScrollView) -> ())?

    /// 1ai 2用户
    private var type = 0
    private var page = 1
    private var dataArray: [MineBlockListModel] = []
    private let bag: DisposeBag = DisposeBag()

    init(frame: CGRect, type: Int) {
        super.init(frame: frame)
        self.type = type
        self.createUI()
        self.createUILimit()
        self.addEvent()
        self.beginRefresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView = BaseTableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundView?.isHidden = true
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 20))
        $0.register(MineBlockListCell.self, forCellReuseIdentifier: MineBlockListCell.description())
    }
}

extension MineBlockListContainerView {
    func loadBlockListData() {
        
        let params = ["type": self.type,
                      "page": self.page]
        
        AppRequest(MineModuleApi.userBlockList(params: params), modelType: TransferMineBlockListModel.self) { [weak self] result, model in
            guard let `self` = self else { return }
            if self.page == 1 {
                self.dataArray.removeAll()
                self.tableView.endRefresh()
            }
            self.tableView.endNextLoadMoreData(next: result.hasNext)
            
            self.page += 1
            self.dataArray.append(contentsOf: result.list)
            self.tableView.backgroundView?.isHidden = self.dataArray.count > 0
            self.tableView.reloadData()
        }errorBlock: { [weak self] code, msg in
            self?.tableView.endRefresh()
        }
    }
    
    private func unblocked(_ id: Int) {
        if type == 1 {
            APPManager.default.aiBlockedReq(mid: id, isBlock: false, complete: nil)
        }else {
            APPManager.default.userBlockedReq(uid: id, isBlock: false, complete: nil)
        }
    }
}

extension MineBlockListContainerView {
    private func createUI() {
        self.addSubview(tableView)
        tableView.backgroundView = BaseTableView.emptyBackgroundView(type: self.type == 1 ? .defaultType : .userList)
    }
    
    private func createUILimit() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addEvent() {
        tableView.addMJRefreshHeader { [weak self] in
            guard let `self` = self else { return }
            self.beginRefresh()
        }
        
        tableView.addMJBackStateFooter { [weak self] in
            guard let `self` = self else { return }
            self.loadBlockListData()
        }
        
        /// 用户拉黑
        NotificationCenter.default.rx.notification(.userBlockedUpdated).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            guard let obj = noti.object as? [String: Any],
                    let uid = obj["uid"] as? Int,
                    let status = obj["status"] as? Bool else { return }
            if status == true {
                self.beginRefresh()
                return
            }
            guard let index = self.dataArray.firstIndex(where: { $0.id == uid }), status == false else { return }
            self.updateUI(index: index)
        }).disposed(by: bag)
        
        /// ai拉黑
        NotificationCenter.default.rx.notification(.aiBlockedUpdated).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            guard let obj = noti.object as? [String: Any],
                    let mid = obj["mid"] as? Int,
                    let status = obj["status"] as? Bool else { return }
            if status == true {
                self.beginRefresh()
                return
            }
            guard let index = self.dataArray.firstIndex(where: { $0.id == mid }), status == false else { return }
            self.updateUI(index: index)
        }).disposed(by: bag)
    }
    
    private func updateUI(index: Int) {
        self.dataArray.remove(at: index)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        self.tableView.endUpdates()
        self.tableView.backgroundView?.isHidden = self.dataArray.count > 0
    }
    
    private func beginRefresh() {
        self.page = 1
        self.loadBlockListData()
    }
}

extension MineBlockListContainerView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineBlockListCell.description(), for: indexPath) as! MineBlockListCell
        cell.loadDataModel(dataArray[indexPath.row])
        cell.clickBlockActionHandle = { [weak self] id in
            guard let `self` = self else { return }
            self.unblocked(id)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        if self.type == 1 {
            APPPushManager.default.pushAIHomePage(mid: model.id, isPresent: true)
        }else {
            APPPushManager.default.pushUserHomePage(uid: model.id)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.listViewDidScrollCallback?(scrollView)
    }
}

extension MineBlockListContainerView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}
