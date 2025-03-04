//
//  AIHomeMainController.swift
//  AIRun
//
//  Created by Bolo on 2025/1/22.
//

import UIKit

/// AI主页
class AIHomeMainController: BaseViewController {
    
    enum AIHomeMainSectionType {
        case banner
        case tags
        case profile
        case creator
    }
    
    var mid = 0
    var isPresent = false
    private var aiMainModel = AIHomeMainModel()
    private var dataArray: [AIHomeMainSectionType] = [.banner, .tags, .profile, .creator]
    
    init (_ mid: Int, aiModel: AIHomeMainModel) {
        super.init(nibName: nil, bundle: nil)
        self.aiMainModel = aiModel
        self.mid = mid
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideNaviBar = true
        self.createUI()
        self.createUILimit()
        self.addEvent()
        self.loadAIMainData()
    }
    
    lazy var tableView = BaseTableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundView = BaseTableView.emptyBackgroundView()
        $0.backgroundView?.isHidden = true
        $0.tableFooterView = self.tableFooterView
        $0.bounces = false // 禁用顶部回弹
        // cell内容间距只算顶部，底部都是0
        $0.register(AIHomeMainBannerCell.self, forCellReuseIdentifier: AIHomeMainBannerCell.description())
        $0.register(AIHomeMainCreatorCell.self, forCellReuseIdentifier: AIHomeMainCreatorCell.description())
        $0.register(AIHomeMainTagsCell.self, forCellReuseIdentifier: AIHomeMainTagsCell.description())
        $0.register(AIHomeMainProfileCell.self, forCellReuseIdentifier: AIHomeMainProfileCell.description())
    }
    
    private lazy var chatBtn = UIButton().then {
        $0.titleLabel?.font = .mediumFont(size: 16)
        let img = UIImage.createButtonImage(type: .normal, size: CGSize(width: UIScreen.screenWidth-96, height: 48))
        $0.setBackgroundImage(img, for: .normal)
        $0.setTitle("Start Chat", for: .normal)
        $0.setTitleColor(UIColor.appBrownColor(), for: .normal)
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
    }
    
    private lazy var tableFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: UIScreen.safeAreaInsets.bottom+48+12))
        view.backgroundColor = .clear
        return view
    }()
}

extension AIHomeMainController {
    private func loadAIMainData() {
        
        if !aiMainModel.profile.isValidStr {
            self.dataArray.removeAll(where: { $0 == .profile })
        }
        self.tableView.reloadData()
    }
    
    /// 打开完整当前AI主页
    private func openFullAIHomePage() {
//        guard self.isPresent else { return }
//        self.dismiss(animated: false) {
//            APPPushManager.default.pushAIHomePage(mid: self.aiMainModel.mid, isPresent: false)
//        }
    }
    
    /// 打开创建者主页
    private func openUserHomePage() {
        self.dismiss(animated: false) {
            APPPushManager.default.pushUserHomePage(uid: self.aiMainModel.creatorInfo.uid)
        }
    }
    
    /// 打开创建者AI区域的AI主页
    private func openCreatorListAI(with mid: Int) {
        self.dismiss(animated: false) {
            APPPushManager.default.pushAIHomePage(mid: mid, isPresent: false)
        }
    }
    
}

extension AIHomeMainController {
    private func createUI() {
        view.addSubview(tableView)
        let backBtn = self.naviBackButton()
        backBtn.isHidden = self.isPresent
        view.addSubview(backBtn)
        view.addSubview(chatBtn)
    }
    
    private func createUILimit() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        chatBtn.snp.makeConstraints { make in
            make.bottom.equalTo(-UIScreen.safeAreaInsets.bottom-18)
            make.leading.trailing.equalToSuperview().inset(48)
            make.height.equalTo(48)
        }
    }
    
    private func addEvent() {
        chatBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: false) {
                APPPushManager.default.pushToChatView(aiMID: self.mid)
            }
        }).disposed(by: bag)
        
    }
}

extension AIHomeMainController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataArray[indexPath.row]
        
        switch type {
        case .banner:
            let cell = tableView.dequeueReusableCell(withIdentifier: AIHomeMainBannerCell.description(), for: indexPath) as! AIHomeMainBannerCell
            cell.configer(model: aiMainModel)
            cell.blockAIHandle = { [weak self] in
                guard let `self` = self else { return }
                if self.isPresent {
                    self.dismiss(animated: true)
                }else {
                    self.naviPopback()
                }
                
            }
            cell.clickBannerHandle = { [weak self] in
                guard let `self` = self else { return }
                self.openFullAIHomePage()
            }
            return cell
        case .tags:
            let cell = tableView.dequeueReusableCell(withIdentifier: AIHomeMainTagsCell.description(), for: indexPath) as! AIHomeMainTagsCell
            cell.showTagsData(aiMainModel.tags)
            return cell
        case .profile:
            let cell = tableView.dequeueReusableCell(withIdentifier: AIHomeMainProfileCell.description(), for: indexPath) as! AIHomeMainProfileCell
            cell.ttLab.attributedText =  aiMainModel.profile.convertToRichText(font: .regularFont(size: 15), color: .whiteColor(alpha: 0.87))
            return cell
        case .creator:
            let cell = tableView.dequeueReusableCell(withIdentifier: AIHomeMainCreatorCell.description(), for: indexPath) as! AIHomeMainCreatorCell
            cell.configer(model: aiMainModel.creatorInfo)
            cell.didClickCreatorAIHandle = { [weak self] mid in
                guard let `self` = self else { return }
                self.openCreatorListAI(with: mid)
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let type = dataArray[indexPath.row]
        
        if type == .creator {
            self.openUserHomePage()
        }else {
            self.openFullAIHomePage()
        }
    }
    
    
}

// MARK: - UIScrollViewDelegate
extension AIHomeMainController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let presentationController = presentationController as? AICustomPresentationController {
            presentationController.adjustHeight(for: scrollView)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 记录开始拖拽时的位置
        scrollView.tag = Int(scrollView.contentOffset.y)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let presentationController = presentationController as? AICustomPresentationController {
            // 如果目标偏移量小于0，强制设置为0，防止越界
            if targetContentOffset.pointee.y < 0 {
                targetContentOffset.pointee.y = 0
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // 如果不会减速，直接检查是否到达顶部
            checkScrollViewAtTop(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 减速结束后检查是否到达顶部
        checkScrollViewAtTop(scrollView)
    }
    
    private func checkScrollViewAtTop(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            // 确保回到顶部时完全复位
            scrollView.setContentOffset(.zero, animated: false)
        }
    }
}
