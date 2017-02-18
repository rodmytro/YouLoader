//
//  YouTubeDownloadController.swift
//  SYCPrototype
//

import Foundation
import XCDYouTubeKit

class YouTubeDownloadController: DownloadController {

    func startDownloading(url: String) {

        //gets URL from identifier and starts downloading
        XCDYouTubeClient.default().getVideoWithIdentifier(getIdentifierFromUrlString(url: url)) {
            (video: XCDYouTubeVideo?, error: Error?) in
            if let video = video {

                let downloadItem = DownloadItem(url: (video.streamURLs.first?.value)!)
                downloadItem.start()

                self.addItem(downloadItem: downloadItem)
            } else {
                print("wrong identifier")
            }
        }

    }

    func getIdentifierFromUrlString(url: String) -> String {
        let index = url.index(url.endIndex, offsetBy: -11)

        return url.substring(from: index)
    }

}
