//
//  SettingController.swift
//  AIRun
//
//  Created by AIRun on 2025/2/5.
//

import UIKit

enum SettingType: String {
    
    case Unfiltered = "Unfiltered Content"
    case account = "Delete Account"
    case policy = "Privacy Policy"
    case termServic = "Terms of Servic"
    case loginout = "Log Out"
    case encryption = "encryption"
    
}

class SettingController: BaseViewController {
    
    private let dataArray: [[SettingType]] = [
        [.Unfiltered],
        [.account],
        [.policy, .termServic],
        [.loginout]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        createUILimit()
        addEvent()
        AppConfig.runningEnvironment
    }
    
    
    private lazy var tableView: BaseTableView = {
        let table = BaseTableView.init(frame: CGRect.zero, style: .grouped)
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.register(SettingTableCell.self, forCellReuseIdentifier: SettingTableCell.description())
        table.register(SettingSwitchTableCell.self, forCellReuseIdentifier: SettingSwitchTableCell.description())
        return table
    }()
    
    lazy var rightView: UIView = {
        let v = UIView()
        v.frame = CGRect(x: 0, y: 0, width: 44, height: UIScreen.navigationBarHeight)
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = true
        return v
    }()
    
}

extension SettingController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tempArr = dataArray[section]
        return tempArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = self.dataArray[indexPath.section][indexPath.row]
        if type == .Unfiltered {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingSwitchTableCell.description(), for: indexPath) as! SettingSwitchTableCell
            cell.configCellData(type: type)
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableCell.description(), for: indexPath) as! SettingTableCell
            cell.configCellData(type: type)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = self.dataArray[indexPath.section][indexPath.row]
        handleCellClick(type: type)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let type = self.dataArray[indexPath.section][indexPath.row]
        if type == .Unfiltered {
            return UITableView.automaticDimension
        }
        return 56
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 12
        case 3:
            return 32
        default:
            return 16
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension SettingController {
    func handleCellClick(type: SettingType) {
        switch type {
        case .account:
            pushToDeleteAccount()
        case .policy:
            APPPushManager.default.pushToWebView(webType: .privacyAgreement)
        case .termServic:
            APPPushManager.default.pushToWebView(webType: .userAgreement)
        case .loginout:
            AppLoginManager.default.loginOutReq()
        default:
            break
        }
    }
    
    private func pushToDeleteAccount() {
        let vc = DeleteAccountController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showDDAlert() {
        let alert = UIAlertController(title: "DD", message: "", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.isSecureTextEntry = true
            tf.placeholder = "password"
        }
        let action1 = UIAlertAction.init(title: "sure", style: .default) { ac in
            if let text = alert.textFields?.first?.text, text == "honey666" {
                let vc = DDViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                self.showErrorTipMsg(msg: "pass word error")
            }
        }
        let action2 = UIAlertAction.init(title: "cancle", style: .cancel)
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true)
    }

}

extension SettingController {
    /// 添加UI
    func createUI() {
        self.title = "Settings"
        view.addSubview(tableView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightView)
    }
    /// 设置约束
    func createUILimit(){
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    ///
    func addEvent() {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 6
        rightView.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.showDDAlert()
        }).disposed(by: bag)
    }
}
