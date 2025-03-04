//
//  AIEditMainTextViewCell.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

// intro & personal
class AIEditMainTextViewCell: AIEditMainCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    override func loadEditMailCell(type: AIEditSectionType, illegal: [Int]) {
        super.loadEditMailCell(type: type, illegal: illegal)
        if type == .intro {
            textView.textView.placeholder = "e.g.{char} is a valiant knight who is silent and reserved, he looks handsome but aloof."
        }else {
            textView.textView.placeholder = "The Long Description allows you to have the Character describe themselves (traits, history, mannerisms, etc), the environmen the character is in and the kinds of things they want to talk about."
        }
        
        textView.snp.updateConstraints { make in
            make.height.equalTo(type == .intro ? 129 : 175)
        }
    }
    
    override func loadEditCellModel(_ model: AIEditingMainModel) {
        super.loadEditCellModel(model)
        if self.type == .intro {
            textView.content = model.intro
        }else {
            textView.content = model.personal
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textView = BaseContainerTextView().then {
        $0.maxLimit = 3000
        $0.isCleanMode = true
    }
}

extension AIEditMainTextViewCell {
    
}

extension AIEditMainTextViewCell {
    private func createUI() {
        contentView.addSubview(textView)
    }
    
    private func createUILimit() {
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(ttLab.snp.bottom).offset(8)
            make.height.equalTo(129)
            make.bottom.equalToSuperview()
        }
    }
    
    private func addEvent() {
        textView.editTextDidChanged = { [weak self] text in
            guard let `self` = self else { return }
            if self.type == .intro {
                self.delegate?.onEditIntro(cell: self, text: text)
            }else {
                self.delegate?.onEditPersonality(cell: self, text: text)
            }
        }
    }
}
