//
//  ViewController.swift
//  Spring Visualizer
//
//  Created by Ray on 7/31/16.
//  Copyright © 2016 Ray. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        view.layer!.backgroundColor = NSColor(hue: 0, saturation: 0, brightness: 0.1, alpha: 1).CGColor
        
        let webView = WKWebView(frame: view.frame)
        view.addSubview(webView)
        
        
        let path = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "HTML")!
        let url = NSURL(fileURLWithPath: path)
        
        webView.setValue(true, forKey: "drawsTransparentBackground")
        webView.loadFileURL(url, allowingReadAccessToURL: url)
    }
    
    
}

