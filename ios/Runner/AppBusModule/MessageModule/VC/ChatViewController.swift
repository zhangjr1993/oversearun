//
//  ChatViewController.swift
//  AIRun
//
//  Created by AIRun on 20247/17.
// markC2CMessageAsRead


import UIKit
import AVFAudio

// MARK: - 属性声明 & 生命周期方法

class ChatViewController: BaseViewController {
    
    
    /// 键盘初始高度
    let chatInputHeight = UIScreen.safeAreaInsets.bottom + 48
    var isInVC = false
    var isActive = true
    var isLoadingMsg = false
    // 开始滑动TableView
    var isBeginDragging = false
    // 记录滑动的位置
    var oldContentOffset = CGPoint.zero

    var isNoMoreMsg: Bool = false {
        didSet {
            self.checkShowTopHeaderInfo()
        }
    }
    var isFirstLoadMsg = true
    var lastMsgGet: V2TIMMessage?
    var msgForDate: V2TIMMessage?
    var uiMsgs: [MsgBaseCellData] = []
    var lastCellData: MsgBaseCellData?
    // 打字机动画
    var isTypewriter = false
    
    var aiMID: Int = 0
    var chatType: ALConversationType = .privete
    var chatInfoModel = ChatInfoDataModel()
  
    init(chatInfo: ChatInfoDataModel, type: ALConversationType) {
        super.init(nibName: nil, bundle: nil)
        self.chatInfoModel = chatInfo
        self.aiMID = chatInfo.mid
        self.chatType = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isInVC = true
        self.readConversationMessage()
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createUI()
        self.createUILimit()
        self.addEvent()
        
        self.loadHistoryMessage()
        if self.chatType == .privete {
            self.readConversationDraft()
            self.unloginInsertOpenMark()
        }
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.readConversationMessage()
        self.isInVC = false
        self.saveConversationDraft()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func naviPopback() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else {
            APPPushManager.default.getCurrentActivityVC()?.navigationController?.popViewController(animated: true)
        }
    }
    
    func naviPush(to vc: BaseViewController) {
        if self.navigationController != nil {
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            APPPushManager.default.getCurrentActivityVC()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    deinit {
        print("dealloc - ALChatViewController")
        APPIMManager.share.removeIMDelegate(self)
    }
   
    lazy var tableView: BaseTableView = {
        let table = BaseTableView.init(frame: CGRect.zero, style: .plain)
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        table.register(MsgTextTableCell.self, forCellReuseIdentifier: MsgTextTableCell.description())
        table.register(MsgTimeTableCell.self, forCellReuseIdentifier: MsgTimeTableCell.description())
        table.register(MsgJumpTableCell.self, forCellReuseIdentifier: MsgJumpTableCell.description())
        table.register(MsgXiaoMiEnumTableCell.self, forCellReuseIdentifier: MsgXiaoMiEnumTableCell.description())
        table.register(MsgTextImageTableCell.self, forCellReuseIdentifier: MsgTextImageTableCell.description())
        table.register(UITableViewCell.self, forCellReuseIdentifier: "MsgCommonTableViewCell")
        return table
    }()
    
   
    lazy var chatInputView: ChatInputView = {
        let view = ChatInputView()
        view.backgroundColor = UIColor.clear
        view.delegate = self
        return view
    }()
    
    lazy var naviBarView = ChatNaviBarView().then {
        $0.backgroundColor = .clear
    }
    
    lazy var checkLoginBtn = UIButton().then {
        $0.backgroundColor = .clear
        $0.isHidden = true
    }
    
    private var scrollWorkItem: DispatchWorkItem?
    
}


// MARK: - TableView Delegate
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uiMsgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellData = uiMsgs[safe: indexPath.row] {
            if cellData.reuseId.isUnValidStr {
                if cellData.isKind(of: MsgTextCellData.self) {
                    cellData.reuseId = MsgTextTableCell.description()
                }
//                else if cellData.isKind(of: MsgImgCellData.self) {
//                    cellData.reuseId = MsgImgTableCell.description()
//                }
                else if cellData.isKind(of: MsgTimeCellData.self) {
                    cellData.reuseId = MsgTimeTableCell.description()
                }else if cellData.isKind(of: MsgJumpCellData.self) {
                    if self.chatType == .privete {
                        cellData.reuseId = MsgJumpTableCell.description()
                    }else {
                        cellData.reuseId = MsgXiaoMiEnumTableCell.description()
                    }
                }else if cellData.isKind(of: MsgTextImageCellData.self) {
                    cellData.reuseId = MsgTextImageTableCell.description()
                }else {
                    let emptyCell = tableView.dequeueReusableCell(withIdentifier: "MsgCommonTableViewCell")
                    return emptyCell!
                }
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellData.reuseId, for: indexPath) as! MsgBaseTableCell
            cell.delegate = self
            cellData.chatType = self.chatType
            cell.fillWithData(data: cellData, chatInfo: self.chatInfoModel)
            return cell
        }else {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "MsgCommonTableViewCell")
            return emptyCell!
        }
    }
}

extension ChatViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        if tableView == scrollView {
            self.oldContentOffset = scrollView.contentOffset
            self.isBeginDragging = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if tableView == scrollView {
            self.isBeginDragging = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView == scrollView {
            /// 是否展开全屏幕
            if isBeginDragging && scrollView.contentOffset.y < -50 {
                self.loadHistoryMessage()
            }
        }
    }
}

extension ChatViewController {
    private func createUI() {
        self.hideNaviBar = true
        self.view.clipsToBounds = true
        self.view.addSubview(naviBarView)
        self.view.addSubview(tableView)

        if self.chatType == .privete {
            self.view.addSubview(chatInputView)
            self.view.addSubview(checkLoginBtn)
            checkLoginBtn.isHidden = APPManager.default.isHasLogin(needJump: false)
        }
        
        naviBarView.loadChatInfo(model: chatInfoModel, type: chatType)
    }
    
    private func createUILimit() {
        naviBarView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.navigationStatusBarHeight)
        }
        if self.chatType == .privete {
            tableView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(naviBarView.snp.bottom)
                make.bottom.equalTo(chatInputView.snp.top)
            }
            chatInputView.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(chatInputHeight)
            }
            checkLoginBtn.snp.makeConstraints { make in
                make.edges.equalTo(chatInputView)
            }
        }else {
            tableView.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(naviBarView.snp.bottom)
            }
        }
        
    }
    
    private func addEvent() {
        APPIMManager.share.addIMDelegate(self)
        
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            self.isActive = false
        }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            self.isActive = true
            self.readConversationMessage()
        }).disposed(by: bag)
        
        naviBarView.backBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.naviPopback()
        }).disposed(by: bag)
        
        naviBarView.userBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            APPPushManager.default.pushAIHomePage(mid: self.aiMID, isPresent: true)
        }).disposed(by: bag)
        
        checkLoginBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: {
            APPManager.default.isHasLogin()
        }).disposed(by: bag)
    }
    
    
    /// force即使最后一个cell 可见也强制滚动
    func scrollToBottom(animated: Bool = true, force: Bool = false) {
        // 取消之前的滚动任务
        scrollWorkItem?.cancel()
        
        // 创建新的滚动任务
        scrollWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self, self.uiMsgs.count > 0 else { return }
            
            let lastIndex = IndexPath(row: self.uiMsgs.count - 1, section: 0)
            
            // 检查最后一个cell是否存在且可见
            let lastCellVisible = self.tableView.indexPathsForVisibleRows?.contains(lastIndex) ?? false
            
            // 如果强制滚动或最后一个cell不可见，则执行滚动
            if force || !lastCellVisible {
                DispatchQueue.main.async {
                    // 使用UIView.animate确保滚动平滑
                    UIView.animate(withDuration: animated ? 0.25 : 0, delay: 0, options: .curveEaseInOut) {
                        // 计算目标偏移量
                        if let lastCell = self.tableView.cellForRow(at: lastIndex) {
                            let cellRect = self.tableView.convert(lastCell.frame, to: self.tableView)
                            let targetOffset = CGPoint(x: 0, y: max(0, cellRect.origin.y - (self.tableView.frame.height - cellRect.height)))
                            
                            // 设置偏移量
                            self.tableView.setContentOffset(targetOffset, animated: false)
                        } else {
                            // 如果cell还未加载，使用scrollToRow
                            self.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
                        }
                        
                        self.tableView.layoutIfNeeded()
                    }
                }
            }
        }
        
        // 延迟执行滚动任务，给UI更新一个缓冲时间
        if let workItem = scrollWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
        }
    }
}
