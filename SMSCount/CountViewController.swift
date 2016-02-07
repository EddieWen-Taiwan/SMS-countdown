//
//  ViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/8.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class CountViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // BACK - for ScreenShot
    @IBOutlet var backRemainedDaysLabel: UILabel!
    @IBOutlet var backRemainedDaysWord: UILabel!
    @IBOutlet var screenShotScale: UIView!

    // FRONT
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var switchViewButton: UIView!
    @IBOutlet var imageOnSwitchBtn: UIImageView!
    var currentDisplay: String

    // RemainedDays
    var countdownView = CountdownView()

    // currentProcess %
    @IBOutlet var pieChartView: UIView!
    @IBOutlet var percentageLabel: UILabel!
    var circleView: PercentageCircleView!
    var isCircleDrawn: Bool

    var calculateHelper = CalculateHelper()
    var loadingView = LoadingView() // LoaingView while taking screenshot

    var downloadFromParse: Bool // Download data from Parse in FriendsTableVC

    required init?(coder aDecoder: NSCoder) {
        self.currentDisplay = "day"
        self.isCircleDrawn = false
        self.downloadFromParse = false

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        let switchGesture = UITapGestureRecognizer(target: self, action: "switchView")
        self.switchViewButton.addGestureRecognizer( switchGesture )
        self.switchViewButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.switchViewButton.layer.borderWidth = 2

        countdownView = CountdownView(view: self.view)
        self.view.addSubview( countdownView )

        circleView = PercentageCircleView( view: self.pieChartView )
        self.pieChartView.addSubview( circleView )

        // Prepare background image
        let currentMonth = NSCalendar.currentCalendar().components( .Month, fromDate: NSDate() ).month
        let currentMonthStr = currentMonth < 10 ? "0" + String(currentMonth) : String(currentMonth)
        MonthlyImages( month: currentMonthStr ).setBackground( self.backgroundImage )

        self.checkSetting()

    }

    func checkSetting() {

        if calculateHelper.settingStatus {

            self.prepareTextAndNumbers()

        } else {
            // switch to settingViewController ?
            // tabBarController?.selectedIndex = 2

            self.percentageLabel.text = "0"
        }

    }

    func prepareTextAndNumbers() {

        let newRemainedDays = calculateHelper.getRemainedDays()

        // For screenshot
        self.backRemainedDaysWord.text = newRemainedDays < 0 ? "自由天數" : "剩餘天數"
        self.backRemainedDaysLabel.text = String( abs(newRemainedDays) )

        // Start animation
        countdownView.setRemainedDays( newRemainedDays )

        self.setTextOfProcess()

    }

    func setTextOfProcess() {

        // Set currentProcess
        let currentProcess = calculateHelper.getCurrentProgress()
        let currentProcessString = String( format: "%.1f", currentProcess )
        self.percentageLabel.text = currentProcessString

        // If user doesn't want animation, do it at this moment
        if let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount") {
            if userPreference.boolForKey("countdownAnimation") == false {
                self.checkCircleAnimation(true)
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Check whether user logged in with FB in FriendsTVC
        if self.downloadFromParse {
            self.downloadFromParse = false

            self.isCircleDrawn = false
            let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!
            userPreference.setBool( false, forKey: "dayAnimated" )

            // Reinit
            calculateHelper = CalculateHelper()
            self.checkSetting()
        }
    }

    func switchView() {

        let switch2chart: Bool = self.currentDisplay == "day" ? true : false
        self.switchViewButton.backgroundColor = UIColor.whiteColor()
        self.imageOnSwitchBtn.image = UIImage(named: switch2chart ? "date" : "chart" )

        UIView.animateWithDuration( 0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.countdownView.alpha = switch2chart ? 0 : 1
            self.pieChartView.alpha = switch2chart ? 1 : 0
            self.switchViewButton.backgroundColor = UIColor(red: 103/255, green: 211/255, blue: 173/255, alpha: 1)
        }, completion: { finish in
            self.currentDisplay = switch2chart ? "chart" : "day"
            if self.calculateHelper.settingStatus {
                if switch2chart {
                    self.checkCircleAnimation(false)
                }
            }
        })

    }

    func checkCircleAnimation( force: Bool ) {
        if force || (self.currentDisplay == "chart" && self.isCircleDrawn == false) {
            self.circleView.addPercentageCircle( (self.percentageLabel.text! as NSString).doubleValue*(0.01) )
            self.isCircleDrawn = true
        }
    }

    @IBAction func pressShareButton(sender: AnyObject) {

        let askAlertController = UIAlertController( title: "分享", message: "將製作分享圖片並可分享至其他平台，要繼續進行嗎？", preferredStyle: .Alert )
        let yesAction = UIAlertAction( title: "確定", style: .Default, handler: {(action) -> Void in

            // START
            self.loadingView = LoadingView(center: CGPointMake(self.view.frame.width/2, (self.view.frame.height-44)/2))
            self.view.addSubview(self.loadingView)
            let indicator = self.loadingView.subviews.first as! UIActivityIndicatorView
                indicator.startAnimating()

            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async( dispatch_get_global_queue( priority, 0 ) ) {
                // do some task

                // Create the UIImage
                // let mainWindowLayer = UIApplication.sharedApplication().keyWindow!.layer
                let mainWindowLayer = self.screenShotScale.layer
                UIGraphicsBeginImageContextWithOptions( CGSize( width: mainWindowLayer.frame.width, height: mainWindowLayer.frame.height ), true, UIScreen.mainScreen().scale )
                mainWindowLayer.renderInContext( UIGraphicsGetCurrentContext()! )
                let screenShot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                // Save it to the camera roll
                UIImageWriteToSavedPhotosAlbum( screenShot, nil, nil, nil )

                sleep(1)

                dispatch_async( dispatch_get_main_queue() ) {
                    // update some UI

                    // Show images picker
                    self.showImagesPickerView()
                }
            }

        })
        let noAction = UIAlertAction( title: "取消", style: .Cancel, handler: nil )

        askAlertController.addAction( yesAction )
        askAlertController.addAction( noAction )

        self.presentViewController( askAlertController, animated: true, completion: nil )

    }

    // the following method is called to show the iOS image picker:
    func showImagesPickerView() {
        if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.SavedPhotosAlbum ) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false

            // Remove loading animation
            self.view.subviews.forEach() {
                if $0 is LoadingView {
                    $0.removeFromSuperview()
                }
            }

            self.presentViewController( imagePicker, animated: true, completion: nil )
        }
    }

    // Once the User selects a photo, the following delegate method is called.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        // Hide imagePickerController
        dismissViewControllerAnimated( false, completion: nil )

        let postImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let activityViewController = UIActivityViewController(activityItems: [postImage], applicationActivities: nil)

        self.presentViewController(activityViewController, animated: true, completion: nil)

    }

}