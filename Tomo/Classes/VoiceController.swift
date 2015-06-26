//
//  VoiceController.swift
//  spot
//
//  Created by Hikaru on 2015/03/12.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import AVFoundation

class VoiceController :NSObject,AVAudioRecorderDelegate{
    
    private var recorder:AVAudioRecorder!
    private var player:AVAudioPlayer!
    private var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    private var path_wav = ""
    //インスタンス
    class var instance : VoiceController {
        struct Static {
            static let instance : VoiceController = VoiceController()
        }
        return Static.instance
    }
    
    //初期化
    private override init() {
        super.init()
        self.path_wav = "\(paths[0])/recorder.wav"//"\(paths[0])/recorder\(NSDate.timeIntervalSinceReferenceDate() * 1000.0).wav"
    }
    
    private func setup(){
        var recordSettings =
        [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 8000.00,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            //AVLinearPCMIsNonInterleaved:false,
            //AVLinearPCMIsBigEndianKey: false,
            //AVLinearPCMIsFloatKey: false,
        ]
        var error:NSErrorPointer = nil
        
        recorder = AVAudioRecorder(URL: NSURL(fileURLWithPath: self.path_wav), settings: recordSettings as [NSObject : AnyObject], error: error)
        recorder.delegate = self
        recorder.meteringEnabled = true
        //creates the file and gets ready to record. happens automatically on record.
        let res = recorder.prepareToRecord()
        println("\(res)")
        println("\(error)")

    }
    func start(){
        if nil == recorder {
            self.setup()
            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,error: nil)
            AVAudioSession.sharedInstance().setActive(true, error: nil)
            
            let status = recorder.record() //start or resume
            println("\(status)")
        }
    }
    func stop()->String?{
        if nil != recorder {
            recorder.stop()
            let path = "\(paths[0])/\(NSUUID().UUIDString.lowercaseString)"
            self.wavToAmr(self.path_wav, savePath: path)
            recorder = nil;
            return path
        }
        return nil
    }

    func playOrStopTest() {
        if player != nil {
            if player.playing {
                player.stop()
                player = nil
                return
            } else {
                player.stop()
                player = nil
            }
        }
        
        let path = NSBundle.mainBundle().pathForResource("test", ofType: "amr")
        
        play(path)
    }
    
    func playOrStop(data: NSData) {
        if player != nil {
            if player.playing {
                player.stop()
                player = nil
                return
            } else {
                player.stop()
                player = nil
            }
        }
        
        let path = paths[0].stringByAppendingPathComponent("test.amr")
        data.writeToFile(path, atomically: true)
        
        play(path)
    }

    func stopPlayer() {
        if player != nil {
            if player.playing {
                player.stop()
                player = nil
                return
            } else {
                player.stop()
                player = nil
            }
        }
    }
    
    func playOrStop(#path: String) {
        if player != nil {
            if player.playing {
                player.stop()
                player = nil
                return
            } else {
                player.stop()
                player = nil
            }
        }
        
        play(path)
    }
    
    func play(path:String!){
        /////
        self.amrToWav(path, savePath: self.path_wav)
        /////
        player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: self.path_wav), error: nil)
//        player.delegate = self
        AVAudioSession.sharedInstance().overrideOutputAudioPort(.Speaker, error: nil)
        
        player.prepareToPlay()
        player.play()
        println("play")
    }
    
    func wavToAmr(wavPath:String,savePath:String){
        EncodeWAVEFileToAMRFile(wavPath.cStringUsingEncoding(NSUTF8StringEncoding)!,savePath.cStringUsingEncoding(NSUTF8StringEncoding)!,1,16)
    }
    func amrToWav(amrPath:String,savePath:String){
        DecodeAMRFileToWAVEFile(amrPath.cStringUsingEncoding(NSUTF8StringEncoding)!,savePath.cStringUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    
}