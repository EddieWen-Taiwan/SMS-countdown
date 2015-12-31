//
//  SettingTableViewController.swift
//  SMSCount
//
//  Created by Eddie on 12/20/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet var enterDateLabel: UILabel!
    @IBOutlet var serviceDaysLabel: UILabel!
    @IBOutlet var discountDaysLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var autoWeekendSwitch: UISwitch!

    let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!

    var parentVC: SettingViewController?

    let calculateHelper = CalculateHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let userEnterDate = self.userPreference.stringForKey("enterDate") {
            self.enterDateLabel.text = userEnterDate
        }
        if let userServiceDays = self.userPreference.stringForKey("serviceDays") {
            self.serviceDaysLabel.text = calculateHelper.switchPeriod( userServiceDays )
        }
        if let userDiscountDays = self.userPreference.stringForKey("discountDays") {
            self.discountDaysLabel.text = userDiscountDays
        }
        if let status = self.userPreference.stringForKey("status") {
            self.statusLabel.text = status
        }
        self.autoWeekendSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8)
        self.autoWeekendSwitch.addTarget(self, action: "switchClick:", forControlEvents: .ValueChanged)
        if self.userPreference.boolForKey("autoWeekendFixed") {
            self.autoWeekendSwitch.setOn(true, animated: false)
        }

        // Add footer of TableView
        let foorterView = UIView(frame: CGRectMake(0,0, tableView.frame.width, 0.5))
        foorterView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        self.tableView.tableFooterView = foorterView
    }

    @IBAction func editEnterDate(sender: AnyObject) {

        if let parentVC = self.parentVC {
            parentVC.serviceDaysPickerViewBottomConstraint.constant = -200
            parentVC.discountDaysPickerViewBottomConstraint.constant = -200
            parentVC.datepickerViewBottomConstraint.constant = 0
            parentVC.screenMask.tag = 1

            parentVC.showPickerView()

            if let userEnterDate = userPreference.stringForKey("enterDate") {
                parentVC.datepickerElement.setDate( parentVC.dateFormatter.dateFromString(userEnterDate)!, animated: false )
            }
        }

    }

    @IBAction func editServiceDays(sender: AnyObject) {

        if let parentVC = self.parentVC {
            parentVC.datepickerViewBottomConstraint.constant = -200
            parentVC.discountDaysPickerViewBottomConstraint.constant = -200
            parentVC.serviceDaysPickerViewBottomConstraint.constant = 0
            parentVC.screenMask.tag = 2

            parentVC.showPickerView()

            if let userServiceDays: Int = userPreference.integerForKey("serviceDays") {
                parentVC.serviceDaysPickerElement.selectRow( userServiceDays, inComponent: 0, animated: false )
            }
        }

    }

    @IBAction func editDiscountDays(sender: AnyObject) {

        if let parentVC = self.parentVC {
            parentVC.datepickerViewBottomConstraint.constant = -200
            parentVC.serviceDaysPickerViewBottomConstraint.constant = -200
            parentVC.discountDaysPickerViewBottomConstraint.constant = 0
            parentVC.screenMask.tag = 3

            parentVC.showPickerView()

            if let selectedRow: Int = userPreference.integerForKey("discountDays") {
                parentVC.discountDaysPickerElement.selectRow( selectedRow, inComponent: 0, animated: false )
            }
        }

    }

    func switchClick( mySwitch: UISwitch ) {
        self.userPreference.setBool( mySwitch.on ? true : false, forKey: "autoWeekendFixed" )
        if let parentVC = self.parentVC {
            parentVC.userInfo.objectIsChanged = true
        }
    }

    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {

        if let statusVC = unwindSegue.sourceViewController as? StatusViewController {
            var userStatus = (statusVC.statusTextField.text ?? "") as NSString
            if userStatus.length > 30 {
                userStatus = userStatus.substringToIndex(30)
            }
            self.statusLabel.text = userStatus as String
            if let parentVC = self.parentVC {
                parentVC.userInfo.updateUserStatus( userStatus as String )
            }
        }

    }

    // MARK: table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 3 : 1
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let label = UILabel(frame: CGRectMake(20, 24, 48, 17))
        label.textColor = UIColor(red: 103/255, green: 211/255, blue: 173/255, alpha: 1)
        label.font = UIFont(name: "PingFangTC-Light", size: 12.0)
        switch section {
            case 0:
                label.text = "個人設定"
            case 1:
                label.text = "一般設定"
            default:
                label.text = "偏好設定"
        }

        let topBorder = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 0.5))
        topBorder.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        let bottomBorder = UIView(frame: CGRectMake(0, 50, tableView.frame.width, 0.5))
        bottomBorder.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)

        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 50))
        headerView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        if section != 0 {
            headerView.addSubview(topBorder)
        }
        headerView.addSubview(bottomBorder)
        headerView.addSubview(label)

        return headerView
    }
}