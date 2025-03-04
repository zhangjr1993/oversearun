//
//  DDViewController.swift
//  AIRun
//
//  Created by Hemming on 2025/2/21.
//

import UIKit


class DDViewController: BaseViewController {
    
    private let dataArray: [[SettingType]] = [
        [.encryption]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        createUILimit()
    }
    
    
    private lazy var tableView: BaseTableView = {
        let table = BaseTableView.init(frame: CGRect.zero, style: .grouped)
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        table.register(DDSwitchTableCell.self, forCellReuseIdentifier: DDSwitchTableCell.description())
        return table
    }()
}

extension DDViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tempArr = dataArray[section]
        return tempArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = self.dataArray[indexPath.section][indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: DDSwitchTableCell.description(), for: indexPath) as! DDSwitchTableCell
        cell.configCellData(type: type)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 56
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}


extension DDViewController {
    /// 添加UI
    func createUI() {
        self.title = "DD"
        view.addSubview(tableView)
    }
    /// 设置约束
    func createUILimit(){
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}


class DDSwitchTableCell: UITableViewCell {

    private let bag: DisposeBag = DisposeBag()
    
    private var type: SettingType?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .appGaryColor()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    private lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .whiteColor(alpha: 0.87)
        lab.font = .regularFont(size: 15)
        lab.textAlignment = .left
        return lab
    }()
    
    
    lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = UIColor.appPinkColor()
        return switchView
    }()
    
}

extension DDSwitchTableCell {
    
    func configCellData(type: SettingType) {
        titleLab.text = type.rawValue
        self.type = type
        switch type {
        case .encryption:
            switchView.isOn = UserDefaults.requestEncryption
        default:
            break
        }
    }
}

extension DDSwitchTableCell {
    private func createUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        contentView.addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(switchView)
    }
    
    private func createUILimit() {
        bgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(15)
        }
        switchView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(titleLab)
        }
        
    }
    
    private func addEvent() {
        
        switchView.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            UserDefaults.requestEncryption = self.switchView.isOn
        }).disposed(by: bag)
        
        
    }

}
