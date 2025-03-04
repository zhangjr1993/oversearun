//
//  HomeSearchController.swift
//  AIRun
//
//  Created by Bolo on 2025/1/20.
//

import UIKit

class HomeSearchController: BaseViewController {
    
    private var dataArray: [HomeSearchModel] = []
    private var searchKeys = ""
    private var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private lazy var navigationBar = HomeSearchBarView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var tableView = BaseTableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.backgroundView = BaseTableView.emptyBackgroundView()
        $0.backgroundView?.isHidden = true
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 20))
        $0.register(HomeSearchCell.self, forCellReuseIdentifier: HomeSearchCell.description())
    }
}

extension HomeSearchController {
    private func startSearchListData() {
        
        if !self.searchKeys.isValidStr {
            self.clearSearch()
            return
        }
        
        let params: [String: Any] = ["page": self.page,
                                     "nickname": self.searchKeys]
        
        AppRequest(HomeModuleApi.searchList(params: params), modelType: TempHomeSearchModel.self) { [weak self] listModel, model in
            guard let `self` = self else { return }
            if self.page == 1 {
                self.dataArray.removeAll()
                self.tableView.endRefresh()
            }
            
            self.tableView.endNextLoadMoreData(next: listModel.hasNext)
            self.page += 1
            self.dataArray.append(contentsOf: listModel.list)
            self.tableView.backgroundView?.isHidden = self.dataArray.count > 0
            self.tableView.reloadData()
        }
    }
    
    private func clearSearch() {
        self.searchKeys = ""
        self.page = 1
        self.dataArray.removeAll()
        self.tableView.reloadData()
    }
}

extension HomeSearchController {
    private func createUI() {
        self.hideNaviBar = true
        self.view.addSubview(navigationBar)
        self.view.addSubview(tableView)
    }
    
    private func createUILimit() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(UIScreen.statusBarHeight)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(42)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func addEvent() {
        tableView.addMJBackStateFooter { [weak self] in
            guard let `self` = self else { return }
            self.startSearchListData()
        }
        
        navigationBar.searchTF.becomeFirstResponder()
        
        navigationBar.backBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.naviPopback()
        }).disposed(by: bag)
        
        navigationBar.sendSearchHandle = { [weak self] keyword in
            guard let `self` = self else { return }
            self.searchKeys = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            self.page = 1
            self.startSearchListData()
        }
        
        navigationBar.clearSearchTextHandle = { [weak self] in
            guard let `self` = self else { return }
            self.clearSearch()
        }
        
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
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        self.tableView.backgroundView?.isHidden = self.dataArray.count > 0
    }
}

extension HomeSearchController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeSearchCell.description(), for: indexPath) as! HomeSearchCell
        cell.loadDataModel(dataArray[indexPath.row], self.searchKeys)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        APPPushManager.default.pushToChatView(aiMID: model.mid)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
