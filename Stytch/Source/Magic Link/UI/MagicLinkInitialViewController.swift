//
//  MagicLinkInitialViewController.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit
import WebKit

class MagicLinkInitialViewController: UIViewController {
    
    // MARK: UI Components
    
    var wkWebView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        return wkWebView
    }()

    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StytchMagicLinkUI.shared.customization.titleStyle.font.withSize(StytchMagicLinkUI.shared.customization.titleStyle.size)
        label.numberOfLines = 0
        label.text = "stytch_login_title".localized
        label.textColor = StytchMagicLinkUI.shared.customization.titleStyle.color
        return label
    }()
    
    var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StytchMagicLinkUI.shared.customization.subtitleStyle.font.withSize(StytchMagicLinkUI.shared.customization.subtitleStyle.size)
        label.numberOfLines = 0
        label.text = "stytch_login_description".localized
        label.textColor = StytchMagicLinkUI.shared.customization.subtitleStyle.color
        return label
    }()
    
    var textField: StytchTextField = {
        let textField = StytchTextField(customization: StytchMagicLinkUI.shared.customization)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholderText = "stytch_login_email_hint".localized
//        textField.text = "edgar@logicants.com"
        return textField
    }()
    
    lazy var actionButton: StytchActionButton = {
        let button = StytchActionButton(customization: StytchMagicLinkUI.shared.customization)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("stytch_login_button_title".localized, for: .normal)
        button.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        return button
    }()
    
    var poweredView: StytchPoweredView = {
        let view = StytchPoweredView(customization: StytchMagicLinkUI.shared.customization)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = StytchMagicLinkUI.shared.customization.backgroundColor.invertedWhiteBlack
        view.isHidden = true
        return view
    }()
    
    // MARK: Parameters
    
    var buttonTopToSubtitileConstraint: NSLayoutConstraint!
    var buttonTopToTextFieldConstraint: NSLayoutConstraint!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = StytchMagicLinkUI.shared.customization.backgroundColor
        
       // StytchMagicLink.shared.delegate = self
        
        hideKeyboardWhenTappedAround()
        
        setupViews()
        
        getUserAgent { (agent) in
            AttributesModel.preloadedAgent = agent
        }
    }
    
    func setupViews() {
        
        var lastTopAnchor = view.safeAreaLayoutGuide.topAnchor
        var lastTopPadding: CGFloat = 32
        
        if StytchMagicLinkUI.shared.customization.showTitle {
            view.addSubview(titleLabel)
            titleLabel.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: lastTopPadding, left: 24, bottom: 0, right: 24))
            
            lastTopAnchor = titleLabel.bottomAnchor
            lastTopPadding = 24
        }
        
        if StytchMagicLinkUI.shared.customization.showSubtitle {
            view.addSubview(subtitleLabel)
            subtitleLabel.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: lastTopPadding, left: 24, bottom: 0, right: 24))
            
            lastTopAnchor = subtitleLabel.bottomAnchor
            lastTopPadding = 24
        }
        
        
        view.addSubview(textField)
        view.addSubview(actionButton)
        
        textField.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: lastTopPadding, left: 24, bottom: 0, right: 24))
        
        actionButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: 0, left: 24, bottom: 0, right: 24))
        
        buttonTopToSubtitileConstraint = actionButton.topAnchor.constraint(equalTo: lastTopAnchor, constant: lastTopPadding)
        buttonTopToTextFieldConstraint = actionButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        buttonTopToTextFieldConstraint.isActive = true
        
        if StytchMagicLinkUI.shared.customization.showBrandLogo {
            view.addSubview(poweredView)
            poweredView.anchor(top: actionButton.bottomAnchor, left: nil, bottom: nil, right: nil, padding: .init(top: 0, left: 24, bottom: 0, right: 24))
            poweredView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func getUserAgent(handler: @escaping (String?)->()){
        wkWebView.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
            handler(result as? String)
        })
    }
    
    // MARK: Actions
    
    @objc func handleActionButton() {
        showLoading()
        if self.textField.isHidden == false {
            Stytch.shared.magicLink.loginOrCreate(email: self.textField.text,
                                         success: { [weak self] email in
                                            self?.hideLoading()
                                            self?.presentConfirmationScreen(email)
                                         },
                                         failure: { [weak self] error in
                                            self?.handleError(error)
                                         })
        } else {
            self.changeToLoginUI()
        }
    }
    
    func showLoading() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideLoading() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
    
    func presentConfirmationScreen(_ email: String) {
        //Present a new VC here. Rather than just changing the UI
        let confirmationPage = MagicLinkConfirmationViewController(email: email)
        self.navigationController?.pushViewController(confirmationPage, animated: true)
    }

    func handleError(_ error: StytchError) {
        hideLoading()
        switch error {
        case .unknown,
             .invalidEmail:
            self.changeToLoginUI()
        case .invalidConfiguration:
            Stytch.shared.magicLink.delegate?.onFailure?(error)
            return
        default:
            break
        }
        
        showAlert(title: "stytch_error_title".localized, message: "\(error.message)")
    }
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func changeUI(buttonText: String, titleText: String, subtitleText: String, showInputField: Bool) {
        UIView.transition(with: titleLabel, duration: 0.3, options: .curveEaseIn) {
            self.titleLabel.alpha = 0
            self.titleLabel.text = titleText
            self.titleLabel.alpha = 1
        } completion: { (_) in
            
        }
        
        UIView.transition(with: subtitleLabel, duration: 0.3, options: .curveEaseIn) {
            self.subtitleLabel.alpha = 0
            self.subtitleLabel.text = subtitleText
            self.subtitleLabel.alpha = 1
        } completion: { (_) in
            
        }
        
        if showInputField {
            
            if self.textField.alpha < 1 {
                
                self.textField.isHidden = false
                self.buttonTopToSubtitileConstraint.isActive = false
                self.buttonTopToTextFieldConstraint.isActive = true
                
                UIView.animate(withDuration: 0.3) {
                    self.textField.alpha = 1
                    self.view.layoutIfNeeded()
                }

            }
            
        } else {
            
            if self.textField.alpha > 0 {
                
                self.buttonTopToTextFieldConstraint.isActive = false
                self.buttonTopToSubtitileConstraint.isActive = true
                
                UIView.animate(withDuration: 0.3) {
                    self.textField.alpha = 0
                    self.view.layoutIfNeeded()
                } completion: { (finished) in
                    if finished {
                        self.textField.isHidden = true
                    }
                }
            }
        }
        
        actionButton.setTitle(buttonText, for: .normal)
        
        hideLoading()
    }
    
    func changeToLoginUI() {
        self.changeUI(buttonText: "stytch_login_button_title".localized,
                      titleText: "stytch_login_title".localized,
                      subtitleText: "stytch_login_description".localized,
                      showInputField: true)
    }
    
    func changeMagicLinkSentUI(email: String) {
        self.changeUI(buttonText: "stytch_login_waiting_verification_button_title".localized,
                      titleText: String(format: "stytch_login_waiting_verification_title".localized, email),
                      subtitleText: "stytch_login_waiting_verification_description".localized,
                 showInputField: false)
    }
}
/*
extension MagicLinkInitialViewController: StytchMagicLinkDelegate {
    
    func onSuccess(_ result: StytchResult) {
        hideLoading()
        dismiss(animated: true) {
            StytchMagicLinkUI.shared.delegate?.onSuccess(result)
        }
    }
    
    
    
    func onMagicLinkSent(_ email: String) {
        //Present a new VC here. Rather than just changing the UI
        let confirmationPage = MagicLinkConfirmationViewController(email: email)
        self.navigationController?.pushViewController(confirmationPage, animated: true)
    }
    
    func onDeepLinkHandled() {
        showLoading()
    }
    
}
*/
