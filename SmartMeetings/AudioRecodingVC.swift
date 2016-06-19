//
//  AudioRecodingVC.swift
//  SmartMeetings
//
//  Created by Manas Sharma on 18/06/16.
//  Copyright © 2016 Manas Sharma. All rights reserved.
//

import UIKit
import AVFoundation
import UIKit
import TextToSpeechV1
import SpeechToTextV1

class AudioRecodingVC: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var ourWave: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var startStopRecordingButton: UIButton!
    @IBOutlet weak var playRecordingButton: UIButton!
    @IBOutlet weak var transcribeButton: UIButton!
    @IBOutlet weak var startStopStreamingDefaultButton: UIButton!
    @IBOutlet weak var startStopStreamingCustomButton: UIButton!
    @IBOutlet weak var transcriptionField: UITextView!
    @IBOutlet weak var markerBtn: UIButton!
    @IBOutlet weak var recordStopRecordingLabel: UILabel!

    
    var stt: SpeechToText?
    var player: AVAudioPlayer? = nil
    var recorder: AVAudioRecorder!
    var isStreamingDefault = false
    var stopStreamingDefault: (Void -> Void)? = nil
    var isStreamingCustom = false
    var stopStreamingCustom: (Void -> Void)? = nil
    var captureSession: AVCaptureSession? = nil
    

    var timer:NSTimer = NSTimer()
    
    var waveformView:SCSiriWaveformView!
    
    
    @IBOutlet weak var newWaveFormView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create file to store recordings
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
                                                            .UserDomainMask, true)[0]
        let filename = "SpeechToTextRecording.wav"
        let filepath = NSURL(fileURLWithPath: documents + "/" + filename)
        
        // set up session and recorder
        let session = AVAudioSession.sharedInstance()
        var settings = [String: AnyObject]()
        settings[AVSampleRateKey] = NSNumber(float: 44100.0)
        settings[AVNumberOfChannelsKey] = NSNumber(int: 1)
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            recorder = try AVAudioRecorder(URL: filepath, settings: settings)
        } catch {
            failure("Audio Recording", message: "Error setting up session/recorder.")
        }
        
        // ensure recorder is set up
        guard let recorder = recorder else {
            failure("AVAudioRecorder", message: "Could not set up recorder.")
            return
        }
        
        // prepare recorder to record
        recorder.delegate = self
        recorder.meteringEnabled = true
        recorder.prepareToRecord()
        
        // disable play and transcribe buttons
        playRecordingButton.enabled = false
        transcribeButton.enabled = false
        
        instantiateSTT()
        
        
        
        

        

    }
    
    func updateMeters() {
        recorder.updateMeters()
        let normalizedValue:CGFloat = pow(10, CGFloat(recorder.averagePowerForChannel(0))/20)
        waveformView.updateWithLevel(normalizedValue)
    }
    
    func instantiateSTT() {
        
        // identify credentials file
        let bundle = NSBundle(forClass: self.dynamicType)
        guard let credentialsURL = bundle.pathForResource("Credentials", ofType: "plist") else {
            failure("Loading Credentials", message: "Unable to locate credentials file.")
            return
        }
        
        // load credentials file
        let dict = NSDictionary(contentsOfFile: credentialsURL)
        guard let credentials = dict as? Dictionary<String, String> else {
            failure("Loading Credentials", message: "Unable to read credentials file.")
            return
        }
        
        // read SpeechToText username
        guard let user = credentials["SpeechToTextUsername"] else {
            failure("Loading Credentials", message: "Unable to read Speech to Text username.")
            return
        }
        
        // read SpeechToText password
        guard let password = credentials["SpeechToTextPassword"] else {
            failure("Loading Credentials", message: "Unable to read Speech to Text password.")
            return
        }
        
        stt = SpeechToText(username: user, password: password)
    }
    
    func eachSec() {
        print(totalNumOfSec)
        //update ui 
        var hours = (totalNumOfSec / 3600)
        var minutes = (totalNumOfSec/60 % 60)
        var seconds = (totalNumOfSec % 60)
        var hoursString : String!
        var minutesString: String!
        var secondsString : String!
        if hours < 10 {
            hoursString = "0\(hours)"
        }
        else {
            hoursString = "\(hours)"
        }

        if minutes < 10 {
            minutesString = "0\(minutes)"        }
        else {
            minutesString = "\(minutes)"
        }

        
        if seconds < 10 {
            secondsString = "0\(seconds)"
        }
        else {
            secondsString = "\(seconds)"
        }


        timeLbl.text = String(hoursString + ":" + minutesString + ":" +  secondsString)        //update flag
        totalNumOfSec++
    }
    
    @IBAction func startStopRecording() {
        
        
        // ensure recorder is set up
        guard let recorder = recorder else {
            failure("Start/Stop Recording", message: "Recorder not properly set up.")
            return
        }
        
        // stop playing previous recording
        if let player = player {
            
            if (player.playing) {
                player.stop()
            }
        }
        
        if (recorder.recording) {
            markerBtn.hidden = false
                    }

        
        // start/stop recording
        if (!recorder.recording) {
            do {
                markerBtn.hidden = true
                let session = AVAudioSession.sharedInstance()
                try session.setActive(true)
                
                timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(AudioRecodingVC.eachSec), userInfo: nil, repeats: true)
                NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)

                
                recorder.record()
                
                
                
                
                
                //        Animations
                
                let bounds = newWaveFormView.bounds

                
                waveformView = SCSiriWaveformView(frame: CGRectMake(0, 0, bounds.width, bounds.height))
                waveformView.waveColor = UIColor.whiteColor()
                waveformView.primaryWaveLineWidth = 3.0
                waveformView.secondaryWaveLineWidth = 1.0
//                self.view.addSubview(waveformView)
                newWaveFormView = waveformView
                newWaveFormView.setNeedsDisplay()
                
                recorder.prepareToRecord()
                recorder.meteringEnabled = true
                recorder.record()
                
                let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(AudioRecodingVC.updateMeters))
                displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
                
                
                
                startStopRecordingButton.setTitle("Stop Recording", forState: .Normal)
                recordStopRecordingLabel.text = "End"
                playRecordingButton.enabled = false
                transcribeButton.enabled = false
                
                totalNumOfSec = 0
                
                markerBtn.hidden = false



            } catch {
                failure("Start/Stop Recording", message: "Error setting session active.")
            }
        } else {
            do {
                
                timeLbl.text = String("00" + ":" + "00" + ":" +  "00")        //update flag
                timer.invalidate()

                recorder.stop()


                recordStopRecordingLabel.text = "Record"

                let session = AVAudioSession.sharedInstance()
                try session.setActive(false)
                startStopRecordingButton.setTitle("Start Recording", forState: .Normal)
                playRecordingButton.enabled = true
                transcribeButton.enabled = true
            } catch {
                failure("Start/Stop Recording", message: "Error setting session inactive.")
            }
        }
    }
    
    @IBAction func playRecording() {
        
        // ensure recorder is set up
        guard let recorder = recorder else {
            failure("Play Recording", message: "Recorder not properly set up")
            return
        }
        
        // play saved recording
        if (!recorder.recording) {
            do {
                player = try AVAudioPlayer(contentsOfURL: recorder.url)
                player?.play()
            } catch {
                failure("Play Recording", message: "Error creating audio player.")
            }
        }
    }
    
    @IBAction func transcribe() {
        
        // ensure recorder is set up
        guard let recorder = recorder else {
            failure("Transcribe", message: "Recorder not properly set up.")
            return
        }
        
        // ensure SpeechToText service is set up
        guard let stt = stt else {
            failure("Transcribe", message: "SpeechToText not properly set up.")
            return
        }
        
        // load data from saved recording
        guard let data = NSData(contentsOfURL: recorder.url) else {
            failure("Transcribe", message: "Error retrieving saved recording data.")
            return
        }
        
        // transcribe recording
        var settings = TranscriptionSettings(contentType: .WAV)
        settings.continuous = true
        settings.model = "en-US_BroadbandModel"
        
        stt.transcribe(data, settings: settings, failure: failureData) { results in
            self.showResults(results)
            var finalTransString = ""
            for result in results {
                finalTransString += " " + result.alternatives[0].transcript
            }
            transString = finalTransString

            let alert = UIAlertView(title: "Summary", message: finalTransString, delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        }
    }
    
    func failure(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default) { action in }
        alert.addAction(ok)
        presentViewController(alert, animated: true) { }
    }
    
    func failureData(error: NSError) {
        let title = "Speech to Text Error:\nTranscribe"
        let message = error.localizedDescription
        failure(title, message: message)
    }
    
    func failureDefault(error: NSError) {
        let title = "Speech to Text Error:\nStreaming (Default)"
        let message = error.localizedDescription
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default) { action in
            self.stopStreamingDefault?()
            self.startStopStreamingDefaultButton.enabled = true
            self.startStopStreamingDefaultButton.setTitle("Start Streaming (Default)",
                                                          forState: .Normal)
            self.isStreamingDefault = false
        }
        alert.addAction(ok)
        presentViewController(alert, animated: true) { }
    }
    
    func failureCustom(error: NSError) {
        let title = "Speech to Text Error:\nStreaming (Custom)"
        let message = error.localizedDescription
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default) { action in
            self.startStopStreamingCustomButton.enabled = true
            self.startStopStreamingCustomButton.setTitle("Start Streaming (Custom)",
                                                         forState: .Normal)
            self.isStreamingCustom = false
        }
        alert.addAction(ok)
        presentViewController(alert, animated: true) { }
    }
    
    func showResults(results: [TranscriptionResult]) {
        var text = ""
        
        for result in results {
            if let transcript = result.alternatives.last?.transcript where result.final == true {
                let title = titleCase(transcript)
                text += String(title.characters.dropLast()) + "." + " "
            }
        }
        
        if results.last?.final == false {
            if let transcript = results.last?.alternatives.last?.transcript {
                text += titleCase(transcript)
            }
        }
        
    }
    
    func titleCase(s: String) -> String {
        let first = String(s.characters.prefix(1)).uppercaseString
        return first + String(s.characters.dropFirst())
    }
    
  
    @IBAction func onClickMarkerBtn(sender: AnyObject) {
        
        lastMarker = totalNumOfSec
    }
    
}
