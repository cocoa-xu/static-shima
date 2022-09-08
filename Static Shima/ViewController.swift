//
//  ViewController.swift
//  static shima
//
//  Created by Cocoa on 08/09/2022.
//

import Cocoa
import MediaPlayer

enum MRCommand: Int {
    case kMRPlay = 0
    case kMRPause = 1
    case kMRTogglePlayPause = 2
    case kMRStop = 3
    case kMRNextTrack = 4
    case kMRPreviousTrack = 5
    case kMRToggleShuffle = 6
    case kMRToggleRepeat = 7
    case kMRStartForwardSeek = 8
    case kMREndForwardSeek = 9
    case kMRStartBackwardSeek = 10
    case kMREndBackwardSeek = 11
    case kMRGoBackFifteenSeconds = 12
    case kMRSkipFifteenSeconds = 13
    case kMRLikeTrack = 0x6A
    case kMRBanTrack = 0x6B
    case kMRAddTrackToWishList = 0x6C
    case kMRRemoveTrackFromWishList = 0x6D
}

class ViewController: NSViewController {
    typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    var MRMediaRemoteGetNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoFunction? = nil

    typealias MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction = @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void
    var MRMediaRemoteGetNowPlayingApplicationIsPlaying: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction? = nil

    typealias MRMediaRemoteRegisterForNowPlayingNotificationsFunction = @convention(c) (DispatchQueue) -> Void
    var MRMediaRemoteRegisterForNowPlayingNotifications: MRMediaRemoteRegisterForNowPlayingNotificationsFunction? = nil

    typealias MRMediaRemoteSendCommandFunction = @convention(c) (Int, NSDictionary?) -> Void
    var MRMediaRemoteSendCommand: MRMediaRemoteSendCommandFunction? = nil

    @IBOutlet weak var nowPlayingLabel: NSTextField!
    @IBOutlet weak var artworkImageView: NSImageView!

    @IBOutlet weak var playPauseButton: NSButton!
    @IBAction func togglePlayPause(_ sender: Any) {
        self.MRMediaRemoteSendCommand?(MRCommand.kMRTogglePlayPause.rawValue, nil)
    }

    @IBAction func backwardPressed(_ sender: Any) {
        self.MRMediaRemoteSendCommand?(MRCommand.kMRPreviousTrack.rawValue, nil)
    }

    @IBAction func forwardPressed(_ sender: Any) {
        self.MRMediaRemoteSendCommand?(MRCommand.kMRNextTrack.rawValue, nil)
    }

    @IBOutlet weak var shimaView: ShimaView!

    func changePlayPauseButtonStatus() {
        self.MRMediaRemoteGetNowPlayingApplicationIsPlaying?(DispatchQueue.main, {isPlaying in
            if isPlaying {
                self.playPauseButton.image = NSImage.init(systemSymbolName: "pause.fill", accessibilityDescription: "Pause")
            } else {
                self.playPauseButton.image = NSImage.init(systemSymbolName: "play.fill", accessibilityDescription: "Play")
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nowPlayingLabel.alignment = .right
    }

    override func viewDidAppear() {
        let window = self.view.window as! ShimaWindow
        window.makeShima()

        let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return }
        self.MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)

        guard let MRMediaRemoteRegisterForNowPlayingNotificationsPtr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString) else { return }
        self.MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPtr, to: MRMediaRemoteRegisterForNowPlayingNotificationsFunction.self)

        guard let MRMediaRemoteSendCommandPtr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString) else { return }
        self.MRMediaRemoteSendCommand = unsafeBitCast(MRMediaRemoteSendCommandPtr, to: MRMediaRemoteSendCommandFunction.self)

        guard let MRMediaRemoteGetNowPlayingApplicationIsPlayingPtr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString) else { return }
        self.MRMediaRemoteGetNowPlayingApplicationIsPlaying = unsafeBitCast(MRMediaRemoteGetNowPlayingApplicationIsPlayingPtr, to: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction.self)

        // Subscribe to now playing info
        self.MRMediaRemoteRegisterForNowPlayingNotifications?(DispatchQueue.main)

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "kMRMediaRemoteNowPlayingInfoDidChangeNotification"), object: nil, queue: nil) { (notification) in
            self.updateNowPlaying()
        }
        self.updateNowPlaying()
    }

    func updateNowPlaying() {
        self.MRMediaRemoteGetNowPlayingInfo?(DispatchQueue.main, { (information) in
            let title = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String
            let artist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String
            let artworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data
            if !(artworkData?.isEmpty ?? true) {
                let artwork = NSImage.init(data: artworkData!)
                self.artworkImageView.image = artwork
            } else {
                self.artworkImageView.image = nil
            }

            var info = ""
            if (title != nil) {
                info = title!
            }
            if (artist != nil) {
                if info.count > 0 {
                    self.nowPlayingLabel.stringValue = "\(info) - \(artist!)"
                } else {
                    self.nowPlayingLabel.stringValue = info
                }
            }
        })
        self.changePlayPauseButtonStatus()
    }
}
