//
//  HomeReportAIPopView.swift
//  AIRun
//
//  Created by Bolo on 2025/1/23.
//

import UIKit

class HomeReportPopView: BasePopView {
    
    enum HomeReportPopType: Int {
        case ai = 1
        case creator = 2
    }
    
    /// 101
    enum HomeReportAIReason: String, CaseIterable {
        case wrong = "This character's rating is wrong. (Belong to NSFW)"
        case spam = "This character contains advertisements, spam."
        case quality = "This character is low-quality."
        case underage = "This Character is underage."
        case nude = "Photos that show genitals or fully-nude."
        case photo = "Use someone else's real photo as the character photo."
        case work = "Plagiarizing others' work."
        case harm = "Promoting suicide or self-harm."
        case org = "Violent or terrorist organizations."
        case content = "Politically sensitive content."
    }
    
    /// 201
    enum HomeReportCreatorReason: String, CaseIterable {
        case other = "Plagiarize the work of others."
        case age = "May be under 18 years of age."
        case comliy = "Posting content that violates community."
    }
    

    private let bag: DisposeBag = DisposeBag()
    private var type: HomeReportPopType = .ai
    private var selectedReason = ""
    private var seletdRid = 0
    private var id = 0
    
    init(type: HomeReportPopType, rid: Int) {
        super.init()
        self.id = rid
        self.type = type
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bgView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var ttLab = UILabel().then {
        $0.text = "Report"
        $0.font = .blackFont(size: 18)
        $0.textColor = .white
    }
    
    private lazy var ddLab = UILabel().then {
        $0.text = "Please select reason:"
        $0.font = .mediumFont(size: 16)
        $0.textColor = .whiteColor(alpha: 0.87)
    }
    
    private lazy var otherLab = UILabel().then {
        $0.text = "Others:"
        $0.font = .mediumFont(size: 16)
        $0.textColor = .whiteColor(alpha: 0.87)
    }
    
    private lazy var submitBtn = UIButton().then {
        let img = UIImage.createButtonImage(type: .normal, size: CGSize(width: UIScreen.screenWidth-96, height: 48), isCorner: 24)
        let img2 = UIImage.createButtonImage(type: .disableNormal, size: CGSize(width: UIScreen.screenWidth-96, height: 48), isCorner: 24)
        $0.isEnabled = false
        $0.setBackgroundImage(img, for: .normal)
        $0.setBackgroundImage(img2, for: .disabled)
        $0.titleLabel?.font = .mediumFont(size: 16)
        $0.setTitle("Submit", for: .normal)
        $0.setTitleColor(UIColor.appBrownColor(), for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.38), for: .disabled)
        $0.clickDurationTime = 1.5
    }
    
    private lazy var closeBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "btn_windows_close"), for: .normal)
    }
  
    private lazy var textView = BaseContainerTextView().then {
        $0.maxLimit = 100
        $0.isCleanMode = true
        $0.isShowLimit = false
        $0.textView.placeholder = "Enter more details..."
        $0.backgroundColor = .whiteColor(alpha: 0.05)
    }
    
    private lazy var tableView = BaseTableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.tableFooterView = self.footerView
        $0.register(HomeReportReasonCell.self, forCellReuseIdentifier: HomeReportReasonCell.description())
    }
    
    private lazy var footerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.screenWidth, height: 95+24))).then {
        $0.backgroundColor = .clear

        $0.addSubview(otherLab)
        $0.addSubview(textView)
    }
}

extension HomeReportPopView {
    private func submitReportAction() {
        guard selectedReason.isValidStr else {
            return
        }
        
        let params: [String: Any] = ["id": self.id,
                                     "reason": self.seletdRid,
                                     "remark": self.textView.content,
                                     "type": self.type.rawValue]
        
        AppRequest(HomeModuleApi.allReport(params: params), modelType: BaseSmartModel.self) { [weak self] result, model in
            guard let `self` = self else { return }
            self.showSuccessTipMsg(msg: "Submitted successfully")
            self.hide()
        }
    }
}

extension HomeReportPopView {
    private func createUI() {
        self.enableTouchHide = false
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        self.addSubview(bgView)
        self.addSubview(ttLab)
        self.addSubview(closeBtn)
        self.addSubview(ddLab)
        self.addSubview(tableView)
        self.addSubview(submitBtn)
    }
    
    private func createUILimit() {
        
        let viewHeight = self.type == .ai ? UIScreen.screenHeight-80 : 467
        
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.screenWidth-48, height: viewHeight))
        }
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        ttLab.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(24)
        }
        closeBtn.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        ddLab.snp.makeConstraints { make in
            make.leading.equalTo(ttLab.snp.leading)
            make.top.equalTo(ttLab.snp.bottom).offset(12)
        }
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(ddLab.snp.bottom).offset(2)
            make.bottom.equalTo(submitBtn.snp.top).offset(-24)
        }
        submitBtn.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
        
        otherLab.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(16)
        }
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(otherLab.snp.bottom).offset(8)
            make.height.equalTo(95)
        }

        self.bgView.addGradientLayer(colors: UIColor.popupBgColors(), frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth-40, height: viewHeight), startPoint: .zero, endPoint: CGPoint(x: 0, y: 1))
        tableView.reloadData()
    }
    
    private func addEvent() {
        submitBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.submitReportAction()
        }).disposed(by: bag)
        
        closeBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification( UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] (notification) in
                guard let self = self else { return }
                self.tableView.contentInset = UIEdgeInsets.zero

            }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification( UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] (notification) in
                guard let self = self else { return }
                let info = notification.userInfo!
                var kbRect = (info[UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue
                kbRect = self.convert(kbRect, from: nil)
                let height = kbRect.size.height - UIScreen.safeAreaInsets.bottom
                let bottom = self.type == .ai ? height-95+16 : 100
                
                self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: bottom, right: 0)
                self.tableView.scrollToBottom()
            }).disposed(by: bag)
    }
}

extension HomeReportPopView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.type == .ai ? HomeReportAIReason.allCases.count : HomeReportCreatorReason.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeReportReasonCell.description(), for: indexPath) as! HomeReportReasonCell
        
        let currentValue: String
        if type == .ai {
            currentValue = HomeReportAIReason.allCases[indexPath.row].rawValue
        }else {
            currentValue = HomeReportCreatorReason.allCases[indexPath.row].rawValue
        }
        
        let selected: Bool = currentValue == selectedReason
        
        cell.bgImgView.image = selected ? cell.lightImage : cell.norImage
        cell.ttLab.textColor = selected ? UIColor.appBrownColor() : UIColor.whiteColor(alpha: 0.87)
        cell.ttLab.text = currentValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentValue: String
        let currentRid: Int
        if type == .ai {
            currentRid = 101 + indexPath.row
            currentValue = HomeReportAIReason.allCases[indexPath.row].rawValue
        }else {
            currentRid = 201 + indexPath.row
            currentValue = HomeReportCreatorReason.allCases[indexPath.row].rawValue
        }
        submitBtn.isEnabled = true
        seletdRid = currentRid
        selectedReason = currentValue
        tableView.reloadData()
    }
}

class HomeReportReasonCell: UITableViewCell {
    
    let lightImage = UIImage.createGradientImg(colors: UIColor.appGradientColor(), size: CGSize(width: UIScreen.screenWidth-80, height: 20))
    let norImage = UIImage.createColorImg(color: UIColor.whiteColor(alpha: 0.05))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear

        contentView.addSubview(bgImgView)
        contentView.addSubview(ttLab)
        
        bgImgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(8)
            make.bottom.equalTo(ttLab.snp.bottom).offset(10)
        }
        ttLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(10)
            make.top.equalTo(18)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var ttLab = UILabel().then {
        $0.textColor = UIColor.whiteColor(alpha: 0.38)
        $0.font = .mediumFont(size: 15)
        $0.numberOfLines = 0
    }
    
    lazy var bgImgView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
        $0.image = norImage
    }
    
}
