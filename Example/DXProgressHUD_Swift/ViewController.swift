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
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.isDiscretionary = true //自由决定选择哪种网络状态进行下载数据
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()

    lazy var downloadTask : URLSessionDownloadTask = {
        let request = URLRequest.init(url: URL(string: "https://hjmys.oss-cn-shenzhen.aliyuncs.com/911f7716b1b4a4edd583dd604db47ae468cf4b65.mp4")!)
        let downloadTask = session.downloadTask(with: request)
        return downloadTask
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "ProgressHUD"
        self.automaticallyAdjustsScrollViewInsets = false
    }
// MARK: - sample
    @IBAction func showSimple(sender: UIButton) {
        // The hud will dispable all input on the view (use the highest view possible in the view hierarchy)
        let HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD)
        
        // Register for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self
        
        // Show the HUD while the provide method  executes in a new thread
        HUD.showWhileExecuting({ [unowned self] in
            self.myTask()
        }, animated: true)
        self.HUD = HUD
    }

    @IBAction func showWithLabel(sender: UIButton) {
        let HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD)
        
        HUD.delegate = self
        HUD.labelText = "Loading"
        
        HUD.showWhileExecuting({ [unowned self] in
            self.myTask()
        }, animated: true)
        self.HUD = HUD
    }

    @IBAction func showWithDetailsLabel(sender: UIButton) {
        let HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD)
        HUD.mode = .text
        HUD.delegate = self
        HUD.labelText = "标题:扎心了"
        HUD.detailsLabelText = "生活不只有眼前的苟且，还有远方的苟且,生活不仅仅是现在的挣扎……还是长期的苟且"
        //HUD!.isSquare = true
        HUD.showWhileExecuting({ [unowned self] in
            self.myTask()
        }, animated: true)
        self.HUD = HUD
    }
    // 0
    @IBAction func showWithLabelDeterminate(sender: UIButton) {
        let HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD)
        
        // Set determinate mode
        HUD.mode = .determinate
        
        HUD.delegate = self
        HUD.labelText = "Loading"
        
        // myProgressTask uses the HUD instance to update progress
        HUD.showWhileExecuting({ [unowned self] in
            self.myProgressTask()
        }, animated: true)
        self.HUD = HUD
    }

    @IBAction func showWithLabelAnnularDeterminate(sender: UIButton) {
        let HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD)
        
        HUD.mode = .annularDeterminate
        
        HUD.delegate = self
        HUD.labelText = "Loading"
        
        // myProgressTask uses the HUD instance to update progress
        HUD.showWhileExecuting({ [unowned self] in
            self.myProgressTask()
        }, animated: true)
        self.HUD = HUD
    }

@IBAction func showWithLabelDeterminateHorizontalBar(sender: UIButton) {
    let HUD = DXProgressHUD(view: self.navigationController!.view)
    self.navigationController!.view.addSubview(HUD)
    
    // Set determinate bar mode
    HUD.mode = .determinateHorizontalBar
    
    HUD.delegate = self
    
    // myProgressTask uses the HUD instance to update progress
    HUD.showWhileExecuting({ [unowned self] in
        self.myProgressTask()
    }, animated: true)
    self.HUD = HUD
}
    // 1
    @IBAction func showWithCustomView(sender: UIButton) {
        let HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD)
        
        // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
        // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
        HUD.customView = UIImageView.init(image: UIImage.init(named: "success"))
        
        // Set custom view mode
        HUD.mode = .customView
        HUD.labelText = "Completed"
        HUD.show(true)
        HUD.hide(true, afterDelay:2)
    }

    @IBAction func showWithLabelMixed(sender: UIButton) {
        let HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD)
        
        HUD.delegate = self
        HUD.labelText = "Connecting"
        HUD.minSize = CGSize.init(width: 135.0, height: 135.0)
        HUD.showWhileExecuting({ [unowned self] in
            self.myMixedTask()
        }, animated: true)
        self.HUD = HUD
    }

    @IBAction func showUsingBlocks(sender: UIButton) {
        let hud: DXProgressHUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(hud)
        
        hud.detailsLabelText = "只有真正努力过的人才知道，天赋是多么的重要。生活不只有眼前的苟且，还有远方的苟且,生活不仅仅是现在的挣扎……还是长期的苟且";
        
        hud.showAnimated(true, whileExecutingBlock: { () -> Void in
            self.myTask()
        }) { () -> Void in
            hud.removeFromSuperview()
        }
    }

    @IBAction func showOnWindow(sender: UIButton) {
        let HUD = DXProgressHUD(view: self.view.window!)
        self.view.window!.addSubview(HUD)
        
        HUD.delegate = self
        HUD.labelText = "Loading"
        HUD.showWhileExecuting({ [unowned self] in
            self.myTask()
        }, animated: true)
        self.HUD = HUD
    }
    
    @IBAction func showURL(sender: UIButton) {
        let HUD = DXProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        HUD.mode = .determinateHorizontalBar
        HUD.delegate = self
        self.downloadTask.resume()
        self.HUD = HUD
    }
    
    @IBAction func showWithGradient(sender: UIButton) {
        let HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD)
        
        HUD.dimBackground = true
        
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        HUD.showWhileExecuting({ [unowned self] in
            self.myTask()
        }, animated: true)
        self.HUD = HUD
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
        let HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD)
        
        // Set the hud to display with a color
        HUD.color = UIColor(red: 0.23, green: 0.50, blue: 0.82, alpha: 0.90)
        HUD.delegate = self;
        HUD.showWhileExecuting({ [unowned self] in
            self.myTask()
        }, animated: true)
        self.HUD = HUD
    }
    // 1
    @IBAction func showSimpleWithIndeterminatedRound(sender: UIButton) {
        // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
        let HUD = DXProgressHUD(view: self.navigationController!.view)
        self.navigationController!.view.addSubview(HUD)
        
        // Register for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self
        
        HUD.mode = .annularIndeterminate
        
        // Show the HUD while the provide method  executes in a new thread
        HUD.showWhileExecuting({ [unowned self] in
            self.myTask()
        }, animated: true)
        self.HUD = HUD
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

        DispatchQueue.main.async {
            self.HUD!.customView = UIImageView(image: UIImage.init(named: "success"))
        }
        HUD!.mode = .customView
        HUD!.labelText = "Completed"
        sleep(2)
    }
    
    // MARK: - DXProgressHUDDelegate
    func hudWasHidden(hud: DXProgressHUD) {
        HUD!.removeFromSuperview()
        HUD = nil
    }
    
}

extension ViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            self.HUD!.customView = UIImageView(image: UIImage.init(named: "success"))
            self.HUD!.mode = .customView
            self.HUD!.hide(true, afterDelay: 2)
        }
    }
    // 下载代理方法，监听下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            
            print(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
            self.HUD!.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }
}
