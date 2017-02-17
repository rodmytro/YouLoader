//
//  DownloadController
//  SYCPrototype

import Foundation
import Alamofire
import XCDYouTubeKit

class DownloadController {

    private var downloads = [DownloadItem]()

    var count: (Int) {
        get{
            return downloads.count
        }
    }
    
    subscript(index: Int) -> DownloadItem {
        get {
            return downloads[index]
        }
    }
    
    func startDownloading(identifier: String) {
        XCDYouTubeClient.default().getVideoWithIdentifier(identifier) {
            (video: XCDYouTubeVideo?, error: Error?) in
            if let video = video {
                let item = DownloadItem(url: (video.streamURLs.first?.value)!, name: video.title);
                item.start()
                self.downloads.append(item)
            }
        }
    }

}
