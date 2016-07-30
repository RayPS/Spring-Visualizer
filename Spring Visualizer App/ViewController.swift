//
//  ViewController.swift
//  Spring Visualizer App
//
//  Created by Ray on 7/30/16.
//  Copyright © 2016 Ray. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    override func prefersStatusBarHidden() -> Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let webView = WKWebView(frame: view.frame)
        view.addSubview(webView)
        webView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.12, alpha: 1)
        
        let path = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "HTML")!
        let url = NSURL(fileURLWithPath: path)
        
        webView.loadFileURL(url, allowingReadAccessToURL: url)
        webView.scrollView.bounces = false
    }

}

