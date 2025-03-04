//
//  SettingCell.swift
//  AIRun
//
//  Created by AIRun on 2025/2/5.
//

import UIKit

class SettingTableCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
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
        return view
    }()
    
    private lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .whiteColor(alpha: 0.87)
        lab.font = .regularFont(size: 15)
        lab.textAlignment = .left
        return lab
    }()
    
    
    private lazy var arrowImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage.imgNamed(name: "btn_login_more_dis")
        return img
    }()
        
    func configCellData(type: SettingType) {
        titleLab.text = type.rawValue
        titleLab.textAlignment = type == .loginout ? .center : .left
        titleLab.textColor = type == .loginout ? .whiteColor(alpha: 0.38) : .whiteColor(alpha: 0.87)
        arrowImg.isHidden = (type == .loginout)

        let rect = CGRect(x: 0, y: 0, width: UIScreen.screenWidth - 32, height: 56)
        switch type {
        case .policy:
            bgView.clipCorner([.topLeft, .topRight], radius: 8, rect: rect)
        case . termServic:
            bgView.clipCorner([.bottomLeft, .bottomRight], radius: 8, rect: rect)
        default:
            bgView.clipCorner([.allCorners], radius: 8, rect: rect)
        }
    }
}

extension SettingTableCell {
    private func createUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        contentView.addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(arrowImg)
        
    }
    
    private func createUILimit() {
        bgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.center.equalToSuperview()
        }
        arrowImg.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(13)
        }
    }
}



class SettingSwitchTableCell: UITableViewCell {

    private let bag: DisposeBag = DisposeBag()
    
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
    lazy var infoLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .whiteColor(alpha: 0.38)
        lab.font = .regularFont(size: 15)
        lab.text = "By turning on Unfiltered Content, you qre enabling potentially sensutuve text."
        lab.textAlignment = .left
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.isUserInteractionEnabled = false
        switchView.tintColor = UIColor.init(hexStr: "#666666")
        switchView.onTintColor = UIColor.appPinkColor()
        switchView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        return switchView
    }()
    
    /// UISwitch没法先拦截点击，所以用一个透明按钮罩住
    lazy var switchBtn = UIButton().then {
        $0.backgroundColor = .clear
    }
}

extension SettingSwitchTableCell {
    
    func configCellData(type: SettingType) {
        titleLab.text = type.rawValue
    }
}

extension SettingSwitchTableCell {
    private func createUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        contentView.addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(switchView)
        bgView.addSubview(infoLab)
        bgView.addSubview(switchBtn)
        
        switchView.isOn = UserDefaults.userUnfilteredStatus
    }
    
    private func createUILimit() {
        bgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(12)
            make.height.equalTo(15)
        }
        switchView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(titleLab)
        }
        switchBtn.snp.makeConstraints { make in
            make.edges.equalTo(switchView)
        }
        
        infoLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.equalTo(titleLab.snp.bottom).offset(6)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    private func addEvent() {
        switchBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            
            if !self.switchView.isOn {
                self.showOpenSwitchPopView()
            }else {
                self.switchView.isOn = false
                UserDefaults.userUnfilteredStatus = false
                self.showSuccessTipMsg(msg: "Switch is of")
            }
            
        }).disposed(by: bag)
    }
   
    private func showOpenSwitchPopView() {
        var config = AlertConfig()
        config.title = "Confirm your age"
        config.content = "By enabling the switch, you'll gain access to the unfiltered content. To view this content, please verify your age."
        config.confirmTitle = "I'm over 18"
        config.cancelTitle = "Go back"
        
        let pop = BaseAlertView(config: config) { [weak self] actionIndex in
            guard let `self` = self else { return }
            if actionIndex == 2 {
                self.switchView.isOn = true
                UserDefaults.userUnfilteredStatus = true
                self.showSuccessTipMsg(msg: "Switch is on")
            }
        }
        pop.show()
    }
}

