//
//  ViewController.swift
//  DXProgressHUD_Swift
//
//  Created by fashion on 2018/8/11.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController,DXProgressHUDDelegate {
    
    var HUD: DXProgressHUD?
    var expectedLength: Int64 = 0
    var currentLength: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "ProgressHUD"
        self.automaticallyAdjustsScrollViewInsets = false
    }

    @IBAction func showSimple(sender: UIButton) {
        // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
        HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD!)
        
        // Register for HUD callbacks so we can remove it from the window at the right time
        HUD!.delegate = self
        
        // Show the HUD while the provide method  executes in a new thread
        HUD!.showWhileExecuting({ [unowned self] () -> Void in
            self.myTask()
            }, animated: true)
    }

    @IBAction func showWithLabel(sender: UIButton) {
        HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD!)
        
        HUD!.delegate = self
        HUD!.labelText = "Loading"
        
        HUD!.showWhileExecuting({ [unowned self] () -> Void in
            self.myTask()
            }, animated: true)
    }

    @IBAction func showWithDetailsLabel(sender: UIButton) {
        HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD!)
        
        HUD!.delegate = self
        HUD!.labelText = "Loading"
        HUD!.detailsLabelText = "赋是多么的重要。生活不只有眼前的苟且，还有远方的苟且,生活不仅仅是现在"
        HUD!.square = true
        
        HUD!.showWhileExecuting({ [unowned self] () -> Void in
            self.myTask()
            }, animated: true)
    }
    // 0
    @IBAction func showWithLabelDeterminate(sender: UIButton) {
        HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD!)
        
        // Set determinate mode
        HUD!.mode = .determinate
        
        HUD!.delegate = self
        HUD!.labelText = "Loading"
        
        // myProgressTask uses the HUD instance to update progress
        HUD!.showWhileExecuting({ [unowned self] () -> Void in
            self.myProgressTask()
            }, animated: true)
    }

    @IBAction func showWithLabelAnnularDeterminate(sender: UIButton) {
        HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD!)
        
        HUD!.mode = .annularDeterminate
        
        HUD!.delegate = self
        HUD!.labelText = "Loading"
        
        // myProgressTask uses the HUD instance to update progress
        HUD!.showWhileExecuting({ [unowned self] () -> Void in
            self.myProgressTask()
            }, animated: true)
    }

@IBAction func showWithLabelDeterminateHorizontalBar(sender: UIButton) {
    HUD = DXProgressHUD(view: self.navigationController!.view)
    self.navigationController!.view.addSubview(HUD!)
    
    // Set determinate bar mode
    HUD!.mode = .determinateHorizontalBar
    
    HUD!.delegate = self
    
    // myProgressTask uses the HUD instance to update progress
    HUD!.showWhileExecuting({ [unowned self] () -> Void in
        self.myProgressTask()
        }, animated: true)
}
    // 1
    @IBAction func showWithCustomView(sender: UIButton) {
        HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD!)
        
        // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
        // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
        HUD!.customView = UIImageView(image: #imageLiteral(resourceName: "chat_sender_bg"))
        
        // Set custom view mode
        HUD!.mode = .customView
        
        HUD!.delegate = self
        HUD!.labelText = "Completed"
        
        HUD!.show(true)
        HUD!.hide(true, afterDelay:3)
    }

    @IBAction func showWithLabelMixed(sender: UIButton) {
        HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD!)
        
        HUD!.delegate = self
        HUD!.labelText = "Connecting"
        HUD!.minSize = CGSize.init(width: 135.0, height: 135.0)
        HUD!.showWhileExecuting({ [unowned self] () -> Void in
            self.myMixedTask()
            }, animated: true)
    }

    @IBAction func showUsingBlocks(sender: UIButton) {
        let hud: DXProgressHUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(hud)
        
        hud.labelText = "只有真正努力过的人才知道，天赋是多么的重要。生活不只有眼前的苟且，还有远方的苟且,生活不仅仅是现在的挣扎……还是长期的苟且";
        
        hud.showAnimated(true, whileExecutingBlock: { () -> Void in
            self.myTask()
        }) { () -> Void in
            hud.removeFromSuperview()
        }
    }

    @IBAction func showOnWindow(sender: UIButton) {
        HUD = DXProgressHUD(view: self.view.window!)
        self.view.window!.addSubview(HUD!)
        
        HUD!.delegate = self
        HUD!.labelText = "Loading"
        HUD!.showWhileExecuting({ [unowned self] () -> Void in
            self.myTask()
            }, animated: true)
    }
    
    @IBAction func showURL(sender: UIButton) {
        
        
        let url: URL = URL.init(string: "http://a1408.g.akamai.net/5/1408/1388/2005110403/1a1a1ad948be278cff2d96046ad90768d848b41947aa1986/sample_iPod.m4v.zip")!

        let request: URLRequest = URLRequest.init(url: url)

        let connection: NSURLConnection? = NSURLConnection(request: request, delegate: self)
        connection!.start()
        
        HUD = DXProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        HUD!.delegate = self
    }
    
    @IBAction func showWithGradient(sender: UIButton) {
        HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD!)
        
        HUD!.dimBackground = true
        
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD!.delegate = self;
        HUD!.showWhileExecuting({ [unowned self] () -> Void in
            self.myTask()
            }, animated: true)
    }

    @IBAction func showTextOnly(sender: UIButton) {
        let hud: DXProgressHUD = DXProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        
        // Configure for text only and offset down
        hud.position = .bottom
        hud.mode = .text
       // hud.labelText = "只有真正努力过的人才赋是多么的重要。生活不只有眼前的苟且，还有远方的苟且,生活不仅仅是现在知道"
        hud.detailsLabelText = "只有真正努力过的人才知道，天赋是多么的重要。生活不只有眼前的苟且，还有远方的苟且,生活不仅仅是现在的挣扎"
        hud.detailsLabelFont = UIFont.systemFont(ofSize: 14)
        hud.margin = 10.0
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 1)
    }

    @IBAction func showWithColor(sender: UIButton) {
        HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD!)
        
        // Set the hud to display with a color
        HUD!.color = UIColor(red: 0.23, green: 0.50, blue: 0.82, alpha: 0.90)
        HUD!.delegate = self;
        HUD!.showWhileExecuting({ [unowned self] () -> Void in
            self.myTask()
            }, animated: true)
    }
    // 1
    @IBAction func showSimpleWithIndeterminatedRound(sender: UIButton) {
        // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
        HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD!)
        
        // Register for HUD callbacks so we can remove it from the window at the right time
        HUD!.delegate = self
        
        HUD!.mode = .annularIndeterminate
        
        // Show the HUD while the provide method  executes in a new thread
        HUD!.showWhileExecuting({ [unowned self] () -> Void in
            self.myTask()
            }, animated: true)
    }
    
    // MARK: - Execution code
    func myTask() {
        // Do something useful in here instead of sleeping...
        sleep(1)
    }
    
    func myProgressTask() {
        // This just incresses the progress indicator in a loop
        var progress: Float = 0.0
        while progress < 1.0 {
            progress += 0.01
            HUD!.progress = progress
            usleep(50000)
        }
    }
    
    func myMixedTask() {
        // Indeterminate mode
        sleep(1)
        // Switch to determinate mode
        HUD!.mode = .determinate
        HUD!.labelText = "Progress"
        var progress: Float = 0.0
        while progress < 1.0 {
            progress += 0.01
            HUD!.progress = progress
            usleep(50000)
        }
        // Back to indeterminate mode
        HUD!.mode = .indeterminate
        HUD!.labelText = "Cleaning up"
        sleep(2)
        // UIImageView is a UIKit class, we have to initialize it on the main thread
        var imageView: UIImageView?
        
        DispatchQueue.main.async {
            let image: UIImage? =  #imageLiteral(resourceName: "chat_sender_bg")
            imageView = UIImageView(image: image)
        }

        HUD!.customView = imageView
        HUD!.mode = .customView
        HUD!.labelText = "Completed"
        sleep(2)
    }
    
    // MARK: - NSURLConnectionDelegate
    func connection(connection: NSURLConnection, didReceiveResponse response: URLResponse) {
        
        expectedLength = max(response.expectedContentLength, 1)
        currentLength = 0
        HUD!.mode = .determinate
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        currentLength = data.length+currentLength
        HUD!.progress = Float(currentLength) / Float(expectedLength)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        HUD!.customView = UIImageView(image:  #imageLiteral(resourceName: "chat_sender_bg"))
        HUD!.mode = .customView
        HUD!.hide(true, afterDelay: 2)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        HUD!.hide(true)
    }
    
    // MARK: - DXProgressHUDDelegate
    func hudWasHidden(hud: DXProgressHUD) {
        HUD!.removeFromSuperview()
        HUD = nil
    }
    
}

