//
//  DeleteAccountController.swift
//  AIRun
//
//  Created by AIRun on 2025/2/6.
//

import UIKit

class DeleteAccountController: BaseViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        createUILimit()
        addEvent()
        // Do any additional setup after loading the view.
    }
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .appYellowColor()
        lab.font = .mediumFont(size: 17)
        lab.text = "Important Notice"
        return lab
    }()
    
    lazy var tipLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .mediumFont(size: 17)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        let text = "Account deletion is an irreversible action. Please proceed with caution. Before proceeding, ensure that all services associated with the account have been properly handled: \n\nPlease note that by deleting your account, you will no longer be able to access or exercise the following rights:\n1.You will no longer be able to log in to this platform with the account.\n2.All information will be permanently deleted (including personal information, various functional records, etc.). \n3.All payment records will be cleared (you may choose to delete your account after your membership expires, or you can forfeit it directly)."

        let dict: [NSAttributedString.Key: Any] = [.font: UIFont.regularFont(size: 15), .foregroundColor: UIColor.white]
        let attributed = NSMutableAttributedString(string: text, attributes: dict)
        attributed.lineSpacing = 4
        lab.attributedText = attributed
        return lab
    }()
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton(type: .custom)
        let bgImg = UIImage.createGradientImg(colors: UIColor.appGradientColor(), size: CGSize(width: (UIScreen.screenWidth-96), height: 48)).isRoundCorner(24)

        btn.setBackgroundImage(bgImg, for: .normal)
        btn.setTitle("Delete Account", for: .normal)
        btn.setTitleColor(UIColor.init(hexStr: "#610134"), for: .normal)
        btn.titleLabel?.font = .mediumFont(size: 16)
        btn.layer.cornerRadius = 24
        return btn
    }()
    

   
    private func showTipAlert() {
        let pop = DeleteAccountPopView()
        pop.show()
    }

}

extension DeleteAccountController {
    /// 添加UI
    func createUI() {
        self.title = "Delete Account"
        view.addSubview(titleLab)
        view.addSubview(tipLab)
        view.addSubview(deleteBtn)

        
    }
    /// 设置约束
    func createUILimit(){
        titleLab.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(16)
        }
        tipLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(titleLab.snp.bottom).offset(10)
        }
        deleteBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(48)
            make.bottom.equalToSuperview().offset(-55 - UIScreen.safeAreaInsets.bottom)
            make.height.equalTo(48)
        }
    }
    ///
    func addEvent() {
        deleteBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.showTipAlert()
        }).disposed(by: bag)
        
        
    }
}

