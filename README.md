# DXProgressHUD_Swift

![demo](./Other/ScreenShots/wechatplugin.png)
![demo1](./Other/ScreenShots/wechatplugin.png)


- [x] 支持自定义View
- [x] 适配了手机横屏显示
- [x] 支持水平进度条显示
- [x] 可灵活显示下载进度条的样式
- [x] 纯文本可自动换行显示
- [x] 支持delegate回调
- [x] 支持block回调


#### block代码示例:
```
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
```

#### delegate代码示例
```
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

func myProgressTask() {
    // This just incresses the progress indicator in a loop
    var progress: Float = 0.0
    while progress < 1.0 {
        progress += 0.01
        HUD!.progress = progress
        usleep(50000)
    }
}

// MARK: - DXProgressHUDDelegate
func hudWasHidden(hud: DXProgressHUD) {
    HUD!.removeFromSuperview()
    HUD = nil
}
```


**注意：bottomj仅纯文本模式下有效**
文件进行了拆分,便于参考学习
本文参考了`powfulhong`[MBProgressHUDForSwift](https://github.com/powfulhong/MBProgressHUDForSwift)
