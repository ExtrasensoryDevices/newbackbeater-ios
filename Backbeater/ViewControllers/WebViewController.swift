//
//  HelpViewController.swift
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-06-10.
//

import UIKit
import WebKit
import MBProgressHUD


class WebViewController: UIViewController { // fixme, WKNavigationDelegate {

//    weak var webView: WKWebView?
    
    var url = HELP_URL
    
    var spinner:MBProgressHUD?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.black.color()
        
        //fixme
//        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
//        webView.navigationDelegate = self
//        webView.backgroundColor = ColorPalette.black.color()
//        webView.isOpaque = false
//
//        self.view.addSubview(webView)
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView":webView]))
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView":webView]))
//
//        _ = webView.load(URLRequest(url: URL(string: url)!))
//
//        self.webView = webView
    }
    
    
    @IBAction func didTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
    

    // MARK: - UIWebViewDelegate
//    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        spinner = MBProgressHUD.showAdded(to: self.view, animated: true)
//    }
//    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        spinner?.hide(animated: true)
//    }
//    
//    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        processError()
//    }
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        processError()
//    }
    
    //FIXME:
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if navigationAction.navigationType == WKNavigationType.linkActivated {
//            if let urlString = navigationAction.request.url?.absoluteString {
//                if urlString.contains(HELP_URL) {
//                    decisionHandler(.allow)
//                    return
//                }
//            }
//            decisionHandler(.allow)
//        }
//        decisionHandler(.allow)
//    }
//    
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        if (navigationType == UIWebViewNavigationType.linkClicked){
//            if let urlString = request.url?.absoluteString {
//                if (urlString.lowercased().range(of: "apphelp") != nil) {
//                    return true
//                }
//            }
//            return !UIApplication.shared.openURL(request.url!)
//        } else {
//            return true
//            
//        }
//    }
    
    private func processError() {
        spinner?.hide(animated: true)
        
        let alertVC = UIAlertController(title: nil, message: "Please check your internet connection or try again later.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in})
        
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    

    
}
