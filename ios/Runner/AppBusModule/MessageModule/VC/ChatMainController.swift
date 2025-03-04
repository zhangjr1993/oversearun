//
//  ChatMainController.swift
//  AIRun
//
//  Created by AIRun on 20248/9.
//

import UIKit

// MARK: - 属性声明 & 生命周期方法

class ChatMainController: BaseViewController {
    
    private var chatSafeArray: ThreadSafeArray<V2TIMConversation> = ThreadSafeArray()

    override func viewWillAppear(_ animated: Bool) {
        hideNaviBar = true
        super.viewWillAppear(animated)
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !APPManager.default.isReachability || !APPIMManager.share.isIMLogin {
            self.onReachabilityChanged(status: false)
        }else {
            self.onReachabilityChanged(status: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createUI()
        self.createUILimit()
        self.addEvent()
        self.initData()
    }
    
    lazy var tableView: BaseTableView = {
        let table = BaseTableView.init(frame: CGRect.zero, style: .plain)
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        table.register(ChatListTableCell.self, forCellReuseIdentifier: ChatListTableCell.description())
        table.backgroundView = BaseTableView.emptyBackgroundView()
        table.backgroundView?.isHidden = true
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 60))
        return table
    }()
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .mediumFont(size: 17)
        lab.text = "Message"
        return lab
    }()
  
    lazy var netTipView: NetTipView = {
        let view = NetTipView()
        view.isHidden = true
        return view
    }()
}

extension ChatMainController {
    private func deleteCell(AtRow indexPath: IndexPath) {
        guard let model = self.chatSafeArray[indexPath.row] else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatListTableCell else { return }
        
        let title = "Are you sure to delete the chat with \(cell.nameLabel.text ?? "")"
        var config = AlertConfig()
        config.content = title
        config.confirmTitle = "Delete"
        
        let alert = BaseAlertView(config: config) { actionIndex in
            guard actionIndex == 2 else { return }
            let reachability = try? Reachability()
            if reachability?.connection == .unavailable {
                self.showErrorTipMsg(msg: "Network connection failed, please try again")
                return
            }
            APPIMManager.share.deleteAiConversation(aiMid: cell.mid, isNeedTip: true)
            self.tableView.reloadData()
        }
        alert.show()
    }
    
    /// IM连接状态
    private func onReachabilityChanged(status: Bool) {
        self.netTipView.isHidden = status
        
        UIView.animate(withDuration: 0.3) {
            self.netTipView.snp.updateConstraints { make in
                make.height.equalTo(status ? 0 : 34)
            }
        }
    }
}


// MARK: - TableView Delegate
extension ChatMainController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatSafeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableCell.description(), for: indexPath) as! ChatListTableCell
        cell.conversationModel = self.chatSafeArray[indexPath.row]
        cell.itemIndex = indexPath.row == 0 ? 0 : indexPath.row == self.chatSafeArray.count-1 ? -1 : 1
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let model = self.chatSafeArray[indexPath.row], (model.userID.intValue == ALConversationType.userSecretaryId.rawValue || model.userID.intValue == ALConversationType.userSystemId.rawValue) {
            APPPushManager.default.pushToChatView(aiMID: model.userID.intValue)
        }else {   
            let filterArr = self.chatSafeArray.filter(isIncluded: {
                $0.userID.intValue == ALConversationType.userSecretaryId.rawValue &&
                $0.userID.intValue == ALConversationType.userSystemId.rawValue 
            })

            if filterArr.count < 3 {
                let model = self.chatSafeArray[indexPath.row]
                APPPushManager.default.pushToChatView(aiMID: model?.userID.intValue ?? 0)
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            self.deleteCell(AtRow: indexPath)
        }
        deleteAction.backgroundColor = UIColor.init(hexStr: "#E94359")
        
        let actions: [UIContextualAction] = [deleteAction]
        let action: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: actions)
        action.performsFirstActionWithFullSwipe = false
        return action
        
    }
}

// MARK: - IMManagerDelegate
extension ChatMainController: IMManagerDelegate {
    func onRefreshConversationList() {
        self.chatSafeArray = APPIMManager.share.convSafeArray
        self.tableView.backgroundView?.isHidden = self.chatSafeArray.count > 0
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
        
    }
    func onLoadConvListFinish(noMoreData: Bool) {
        self.tableView.endRefresh()
        if noMoreData {
            self.tableView.mj_footer = nil
        }
    }
}

// MARK: - Layout
extension ChatMainController{
   
    private func createUI() {
        self.hideNaviBar = true
        self.view.addSubview(titleLab)
        self.view.addSubview(tableView)
        self.view.addSubview(netTipView)
    }
    
    private func createUILimit() {
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(UIScreen.statusBarHeight)
            make.height.equalTo(UIScreen.navigationBarHeight)
            make.leading.equalTo(16)
        }
        netTipView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(34)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(netTipView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func addEvent() {
        APPIMManager.share.addIMDelegate(self)
        
        tableView.addMJRefreshHeader { [weak self] in
            guard let `self` = self else { return }
            APPIMManager.share.refreshChatListCacheDataQuery(safeArray: self.chatSafeArray)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.tableView.reloadData()
                self.tableView.endRefresh()
            })
        }
        tableView.addMJBackStateFooter { 
            APPIMManager.share.getHistoryConversation()
        }
        
        APPManager.default.isReachabilitySubject.subscribe(onNext: { [weak self] status in
            guard let `self` = self else { return }
            self.onReachabilityChanged(status: (status && APPIMManager.share.isIMLogin))
        })
    }
    
    private func initData() {
        self.chatSafeArray = APPIMManager.share.convSafeArray
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            APPIMManager.share.nextSeq = 0
            APPIMManager.share.getHistoryConversation()
        })        
    }
    
}
