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
    
    override var prefersStatusBarHidden : Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let webView = WKWebView(frame: view.frame)
        view.addSubview(webView)
        webView.backgroundColor = view.backgroundColor
        
        let path = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "HTML")!
        let url = URL(fileURLWithPath: path)
        
        webView.loadFileURL(url, allowingReadAccessTo: url)
        webView.scrollView.bounces = false
    }

}

