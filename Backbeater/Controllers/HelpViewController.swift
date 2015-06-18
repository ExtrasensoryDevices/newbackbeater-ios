//
//  HelpViewController.swift
//  Backbeater
//
//  Created by Alina on 2015-06-10.
//

import UIKit

class HelpViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(NSURLRequest(URL: NSURL(string: HELP_URL)!))
    }
    
    
    @IBAction func didTapClose() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    // MARK: - UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        activityIndicator.stopAnimating()
        let alertVC = UIAlertController(title: nil, message: "Please check your internet connection or try again later.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
        
        alertVC.addAction(okAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
 
}
