//
//  HighlightedVC.swift
//  SmartMeetings
//
//  Created by Manas Sharma on 19/06/16.
//  Copyright © 2016 Manas Sharma. All rights reserved.
//

import UIKit
import AVFoundation

class HighlightedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var player : AVAudioPlayer?
    var timer2 = NSTimer()
    var timevar = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var recording: Recording?
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: RecordCell = self.tableView.dequeueReusableCellWithIdentifier("mycell") as! RecordCell
        
        cell.tagLbl.text = DataSource[indexPath.row].tagString
        
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("play audio here")
        
         recording = DataSource[indexPath.row]
        
        
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
                                                            .UserDomainMask, true)[0]
        let filename = "SpeechToTextRecording.wav"
        let filepath = NSURL(fileURLWithPath: documents + "/" + filename)
        
        do {
            player = try AVAudioPlayer(contentsOfURL: filepath)
            player?.currentTime = NSTimeInterval(recording!.startTime!)
            player?.play()
            
            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(recording!.endTime! - recording!.startTime!), target: self, selector: #selector(HighlightedVC.stopPlayer), userInfo: nil, repeats: false)
        }
        catch{
            print("failed")
        }
    }
    func nothing() {
        timevar++
        if timevar == ((recording?.endTime)! - (recording?.startTime)!) {
            timer2.invalidate()
            player?.stop()
        }
    }
    
    func stopPlayer() {
       
        player?.stop()

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.count
    }

    @IBAction func onClickClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onPlay(sender: AnyObject) {
        

    }
}
