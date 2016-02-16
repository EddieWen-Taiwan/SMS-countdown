//
//  CountdownView.swift
//  SMSCount
//
//  Created by Eddie on 2/6/16.
//  Copyright © 2016 Wen. All rights reserved.
//

import UIKit

class CountdownView: UIView {

    var dayLabel = UILabel()
    var textLabel = UILabel()

    var animationIndex: Int = 0
    var animationArray = [String]() // [ 1, 2, ... 99, 100 ]
    var stageIndexArray = Array(count: 6, repeatedValue: 0)

    convenience init(view: UIView) {
        self.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-44-49))

        self.addDaysLabel()
        self.addTextLabel()
    }

    private func addDaysLabel() {

        self.dayLabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, 60))
        self.dayLabel.center = self.center
        self.dayLabel.font = UIFont(name: "Verdana", size: 74)
        self.dayLabel.textColor = UIColor.whiteColor()
        self.dayLabel.textAlignment = .Center

        self.addSubview( self.dayLabel )

    }

    private func addTextLabel() {

        self.textLabel = UILabel(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height-44-49)/2+110, UIScreen.mainScreen().bounds.width, 23))
        self.textLabel.font = UIFont(name: "PingFangTC-Regular", size: 16)
        self.textLabel.textColor = UIColor.whiteColor()
        self.textLabel.textAlignment = .Center

        self.addSubview( self.textLabel )

    }

    func setRemainedDays( days: Int ) {

        self.textLabel.text = days < 0 ? "自由天數" : "剩餘天數"

        // Set remainedDays
        if let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount") {
            if userPreference.boolForKey("countdownAnimation") == true && userPreference.boolForKey("dayAnimated") == false {
                // Run animation
                self.beReadyAndRunCountingAnimation( abs(days) )
            } else {
                // Animation was completed or User doesn't want animation
                self.dayLabel.text = String( abs(days) )
            }
        }

    }

    private func beReadyAndRunCountingAnimation( days: Int ) {

        // Animation setting
        self.animationIndex = 0
        self.animationArray.removeAll(keepCapacity: false) // Maybe it should be true

        if days < 100 {
            for i in 1 ... days {
                self.animationArray.append( String(i) )
            }
        } else {
            for i in 1 ... 95 {
                self.animationArray.append( String( format: "%.f", Double( (days-3)*i )*0.01 ) )
            }
            for i in 96 ... 100 {
                self.animationArray.append( String( days-(100-i) ) )
            }
        }

        let arrayLength = self.animationArray.count
        self.stageIndexArray.removeAll(keepCapacity: true)
        self.stageIndexArray.append( Int( Double(arrayLength)*0.55 ) )
        self.stageIndexArray.append( Int( Double(arrayLength)*0.75 ) )
        self.stageIndexArray.append( Int( Double(arrayLength)*0.88 ) )
        self.stageIndexArray.append( Int( Double(arrayLength)*0.94 ) )
        self.stageIndexArray.append( Int( Double(arrayLength)*0.97 ) )
        self.stageIndexArray.append( arrayLength-1 )

        self.dayLabel.text = "0"

        // Run animation
        NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("daysAddingEffect:"), userInfo: ["index": 0], repeats: true )

    }

    private func startNextTimer( stage: Int ) {
        let interval: Double = 0.01*pow( Double(2), Double(stage) )
        let info: Dictionary<String,Int> = [ "index": stage ]

        NSTimer.scheduledTimerWithTimeInterval( interval, target: self, selector: Selector("daysAddingEffect:"), userInfo: info, repeats: true )
    }

    func daysAddingEffect( timer: NSTimer ) {

        if let info = timer.userInfo as? Dictionary<String,Int> {
            if let currentIndex = info["index"] {
                if self.animationIndex < self.stageIndexArray[currentIndex] {
                    self.updateLabel()
                } else {
                    timer.invalidate()
                    self.startNextTimer( currentIndex+1 )
                }
            }
        }

    }

    private func updateLabel() {
        self.dayLabel.text = self.animationArray[ self.animationIndex++ ]
    }

}
