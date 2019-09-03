//
//  HelpViewController.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-06-10.
//

import UIKit
import WebKit


class WebViewController: UIViewController, WKNavigationDelegate {

    weak var webView: WKWebView?
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var goBackButton: UIBarButtonItem!
    @IBOutlet weak var goForwardButton: UIBarButtonItem!
    
    var url = HELP_URL
    
    @IBOutlet weak var closeButton: UIButton!
    var spinner: UIActivityIndicatorView?
    
    var isFirst: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.black.color
        
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.backgroundColor = ColorPalette.black.color
        webView.isOpaque = false

//        webView.frame = self.view.bounds
//        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(webView, belowSubview: closeButton)
//        self.view.autoresizesSubviews = true
        
        let winSize = UIScreen.main.bounds.size
        
        if winSize.height/winSize.width > 2 {
            webView.frame = CGRect(x: 0, y: 0, width: winSize.width, height: winSize.height-80)
        }
        else {
            webView.frame = CGRect(x: 0, y: 0, width: winSize.width, height: winSize.height-44)
        }

        webView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["webView":webView]))
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["webView":webView]))

        _ = webView.load(URLRequest(url: URL(string: url)!))

        webView.isHidden = true
        self.webView = webView
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func didTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTappedGoBack(_ sender: Any) {
        self.webView!.goBack()
    }

    @IBAction func onTappedGoForward(_ sender: Any) {
        self.webView!.goForward()
    }

    // MARK: - UIWebViewDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if isFirst {
            isFirst = false
            showSpinner()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
        toolbar.isHidden = false
        goBackButton.isEnabled = webView.canGoBack
        goForwardButton.isEnabled = webView.canGoForward
        hideSpinner()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        processError(error)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        processError(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
//        if navigationAction.navigationType == .linkActivated {
//            if let url = navigationAction.request.url {
////               if url.absoluteString.contains("apphelp") {
//                    decisionHandler(.allow)
//                    return
////                }
////                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
//            decisionHandler(.cancel)
//        } else {
            decisionHandler(.allow)
//        }
    }
    
    private func processError(_ error: Error) {
        hideSpinner()
        
        let alertVC = UIAlertController(title: nil, message: "Please check your internet connection or try again later.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in})
        
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    

    private func showSpinner() {
        hideSpinner()
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        spinner.center = view.center
        spinner.startAnimating()
        view.addSubview(spinner)
        self.spinner = spinner
    }
    private func hideSpinner() {
        spinner?.removeFromSuperview()
        spinner = nil
    }
}

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
