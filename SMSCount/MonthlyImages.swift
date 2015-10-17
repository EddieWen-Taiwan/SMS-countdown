//
//  BackImageUpdate.swift
//  SMSCount
//
//  Created by Eddie on 2015/10/9.
//  Copyright © 2015年 Wen. All rights reserved.
//

class MonthlyImages {

    let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!
    let path: String
    var currentMonth = "0"

    init(month: String, background: UIImageView) {
        self.currentMonth = month

        // update and svae image
        let documentURL = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask )[0]
        path = documentURL.URLByAppendingPathComponent("backgroundImage").path!

        if self.isMonthMatch() {
            background.image = UIImage(contentsOfFile: path)
        } else {
            background.alpha = 0

            let urlString = "http://smscount.lol/app/backgroundImg/" + self.currentMonth
            self.downloadImage( NSURL(string: urlString)!, backgroundImage: background )
        }
    }

    private func downloadImage( url: NSURL, backgroundImage: UIImageView ) {
        self.getImageFromUrl(url) { (data, response, error)  in

            if data == nil {
                backgroundImage.backgroundColor = UIColor(patternImage: UIImage(named: "default-background")!)
            } else {
                dispatch_async( dispatch_get_main_queue() ) { () -> Void in
                    self.saveImage( UIImage(data: data!)! )
                    self.userPreference.setObject( self.currentMonth, forKey: "backgroundMonth" )
                    backgroundImage.image = UIImage(data: data!)
                    
                    UIView.animateWithDuration( 1, animations: {
                        backgroundImage.alpha = 1
                    })
                }
            }

        }
    }

    private func getImageFromUrl( url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void) ) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
        }.resume()
    }

    private func saveImage( image: UIImage ) {
        let pngImageData = UIImagePNGRepresentation(image)!
//        NSFileManager.removeItemAtPath( self.path )
        pngImageData.writeToFile( self.path, atomically: true )
    }

    private func isMonthMatch() -> Bool {
        let imageMonth = userPreference.stringForKey("backgroundMonth")
        return imageMonth == currentMonth ? true : false
    }

}