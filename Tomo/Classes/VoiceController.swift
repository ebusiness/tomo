//
//  VoiceController.swift
//  Tomo
//
//  Created by Hikaru on 2015/03/12.
//  Copyright © 2015年 e-business. All rights reserved.
//

import AVFoundation

class VoiceController: NSObject,AVAudioRecorderDelegate{

    private var recorder: AVAudioRecorder!
    private var player: AVAudioPlayer!
    private var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    private var pathWav = ""
    //インスタンス
    class var instance: VoiceController {
        struct Static {
            static let instance: VoiceController = VoiceController()
        }
        return Static.instance
    }

    //初期化
    private override init() {
        super.init()
        self.pathWav = "\(paths[0])/recorder.wav"//"\(paths[0])/recorder\(NSDate.timeIntervalSinceReferenceDate() * 1000.0).wav"
    }

    private func setup(){
        let recordSettings: [String: Any] =
        [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 8000.00,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            //AVLinearPCMIsNonInterleaved: false,
            //AVLinearPCMIsBigEndianKey: false,
            //AVLinearPCMIsFloatKey: false,
        ]

        do {
            recorder = try AVAudioRecorder(url: URL(fileURLWithPath: self.pathWav), settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            //creates the file and gets ready to record. happens automatically on record.
            recorder.prepareToRecord()
//          println("\(res)")
//          println("\(error)")
        } catch {

        }

    }
    func start(){
        if nil == recorder {
            self.setup()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,with: .defaultToSpeaker)
                try AVAudioSession.sharedInstance().setActive(true)
                recorder.record() //start or resume
            } catch {

            }
        }
    }
    func stop()-> (String, String)?{
        if nil == recorder { return nil }

        recorder.stop()
        let name = NSUUID().uuidString.lowercased()
        let path = "\(paths[0])/\(name)"
        self.wavToAmr(wavPath: self.pathWav, savePath: path)
        recorder = nil;
        return (path, name)
    }

    func playOrStopTest() {
        if player != nil {
            if player.isPlaying {
                player.stop()
                player = nil
                return
            } else {
                player.stop()
                player = nil
            }
        }

        let path = Bundle.main.path(forResource: "test", ofType: "amr")

        play(path: path)
    }

    func playOrStop(data: NSData) {
        if player != nil {
            if player.isPlaying {
                player.stop()
                player = nil
                return
            } else {
                player.stop()
                player = nil
            }
        }

        let path = "\(paths[0])/test.amr"
        data.write(toFile: path, atomically: true)

        play(path: path)
    }

    func stopPlayer() {
        if nil == player { return }
        if player.isPlaying {
            player.stop()
            player = nil
            return
        } else {
            player.stop()
            player = nil
        }
    }

    func playOrStop(path filepath: String) {
        if player != nil {
            if player.isPlaying {
                player.stop()
                player = nil
                return
            } else {
                player.stop()
                player = nil
            }
        }

        play(path: filepath)
    }

    func play(path: String!){
        /////
        self.amrToWav(amrPath: path, savePath: self.pathWav)
        /////
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.pathWav), fileTypeHint: nil)
//            player.delegate = self
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)

            player.prepareToPlay()
            player.play()
        } catch {

        }
    }

    func wavToAmr(wavPath: String,savePath: String){
        EncodeWAVEFileToAMRFile(wavPath.cString(using: String.Encoding.utf8)!,savePath.cString(using: String.Encoding.utf8)!,1,16)
    }
    func amrToWav(amrPath: String,savePath: String){
        DecodeAMRFileToWAVEFile(amrPath.cString(using: String.Encoding.utf8)!,savePath.cString(using: String.Encoding.utf8)!)
    }

}
