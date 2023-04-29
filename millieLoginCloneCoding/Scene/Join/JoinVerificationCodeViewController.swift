//
//  JoinVerificationCodeViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit

class JoinVerificationCodeViewController: UIViewController {
    private var loginVM: LoginProtocol?
    
    @IBOutlet weak var verificationCodeInputView: InputStackView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    required init?(coder: NSCoder, loginVM: LoginProtocol?) {
        self.loginVM = loginVM
        super.init(coder: coder)
    }
    
    @available(*, unavailable, renamed: "init(coder:delegate:)")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setAttribute()
    }
    
    private func setAttribute(){
        verificationCodeInputView.delegate = self
        
        nextButton.layer.cornerRadius = 5
    }
    
    @IBAction func resendButtonTap(_ sender: UIButton) {
        loginVM?.requestVerificationCode(){result in
            if result{
                //재전송
            }else{
                //싫패
            }
        }
    }
    
    @MainActor
    @IBAction func nextButtonTap(_ sender: UIButton) {
        guard let verificationCode = verificationCodeInputView.textField.text else {return}
        
        Task{
            do{
                try await loginVM?.phoneNumberLogin(verificationCode: verificationCode)
                let joinProfileViewController =  UIStoryboard(name: "Join", bundle: nil)
                    .instantiateViewController(identifier: "JoinProfileViewController"){ (coder) -> JoinProfileViewController? in
                    return .init(coder: coder, loginVM: self.loginVM)
                }
                
                self.navigationController?.pushViewController(joinProfileViewController, animated: true)
            }
            catch{
                presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
}

extension JoinVerificationCodeViewController: InputStackViewDelegate{
    func inputTextFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text == "" {
            nextButton.isEnabled = false
        }
        else{
            nextButton.isEnabled = true
        }
    }
    
    func inputTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        true
    }
}
