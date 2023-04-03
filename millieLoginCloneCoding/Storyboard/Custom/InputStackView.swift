//
//  InputStackView.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/03.
//

import UIKit

@objc protocol InputStackViewDelegate: NSObjectProtocol{
    @objc optional func textFieldDidChangeSelection(_ textField: UITextField)
    @objc optional func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
}

@IBDesignable
class InputStackView: UIView {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBInspectable var text: String? {
        get{
            return titleLabel.text
        }
        set{
            titleLabel.text = newValue
        }
    }
    @IBInspectable var placeholder: String?{
        get{
//            let textField: UITextField! = filed as? UITextField
            return  textField.placeholder ?? ""
        }
        set{
            textField.placeholder = newValue
        }
    }
    @IBInspectable var secureTextEntry: Bool{
        get{
            return  textField.isSecureTextEntry
        }
        set{
            textField.isSecureTextEntry = newValue
        }
    }
    @IBInspectable var keyboardNumberPad: Bool{
        get{
            return  textField.keyboardType == .numberPad
        }
        set{
            textField.keyboardType = newValue ? .numberPad : .default
        }
    }
    
    var delegate: InputStackViewDelegate? {
        didSet {
            textFieldDidChangeSelection(textField)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        setAttribute()
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib(nib: "InputStackView") else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        //코드 오토레이아웃을 사용할 경우? 스토리보드에서 확인 불가
//        view.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(view)
//        NSLayoutConstraint.activate([
//            leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            topAnchor.constraint(equalTo: view.topAnchor),
//        ])
    }
    
    private func setAttribute(){
        textField.delegate = self
        
        stackView.layer.cornerRadius = 5
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.lightGray.cgColor
    }
}

extension InputStackView: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //시작
        stackView.layer.borderColor = UIColor.black.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //끝
        stackView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.textFieldDidChangeSelection?(textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}

extension UIView {
    func loadViewFromNib(nib: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nib, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
