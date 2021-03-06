//
//  TodayViewController.swift
//  SMS_Widget
//
//  Created by Eddie on 2015/8/20.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet var remainedDaysLabel: UILabel!
    @IBOutlet var warningLabel: UILabel!

    @IBOutlet var firstWord: UILabel!
    @IBOutlet var secondWord: UILabel!

    let calculateHelper = CalculateHelper()
    var updateResult: NCUpdateResult

    var isUserRetired: Bool

    required init?(coder aDecoder: NSCoder) {
        self.updateResult = NCUpdateResult.noData
        self.isUserRetired = false

        super.init(coder: aDecoder)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // checkCurrentData
        if calculateHelper.settingStatus {

            self.correctDataShow( true )

            let newRemainedDays = calculateHelper.getRemainedDays()
            if self.isDataChanged( newRemainedDays ) {
                if newRemainedDays >= 0 {
                    self.firstWord.text = "還有"
                    self.remainedDaysLabel.text = String( newRemainedDays )
                } else {
                    self.firstWord.text = "自由"
                    self.remainedDaysLabel.text = String( newRemainedDays*(-1) )
                }

                self.updateResult = NCUpdateResult.newData
            }

        } else {
            self.correctDataShow( false )
        }
    }

    // Check whether should run countdown animation
    fileprivate func isDataChanged( _ day: Int ) -> Bool {

        if day >= 0 {
            if self.isUserRetired {
                self.isUserRetired = false
                return true
            } else {
                if self.remainedDaysLabel.text != String( day ) {
                    return true
                }
            }
        } else {
            if self.isUserRetired {
                if self.remainedDaysLabel.text != String( day*(-1) ) {
                    return true
                }
            } else {
                self.isUserRetired = true
                return true
            }
        }

        return false

    }

    fileprivate func correctDataShow( _ status: Bool ) {

        remainedDaysLabel.isHidden = status ? false : true
        firstWord.isHidden = status ? false : true
        secondWord.isHidden = status ? false : true

        warningLabel.isHidden = status ? true : false

    }

    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: defaultMarginInsets.top,
            left: defaultMarginInsets.left,
            bottom: 5.0,
            right: defaultMarginInsets.right )
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler( self.updateResult )
    }

}
