//
//  HelpViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-10.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    
    var url = HELP_URL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
    }
    
    
    @IBAction func didTapClose() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    // MARK: - UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        let alertVC = UIAlertController(title: nil, message: "Please check your internet connection or try again later.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
        
        alertVC.addAction(okAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
 
}
