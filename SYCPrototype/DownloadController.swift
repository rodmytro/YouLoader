//
//  DownloadController
//  SYCPrototype

import Foundation

class DownloadController: Sequence {

    private var downloads = [DownloadItem]()

    var count: (Int) {
        get {
            return downloads.count
        }
    }

    subscript(index: Int) -> DownloadItem {
        get {
            return downloads[index]
        }
    }

    deinit {
        for item in downloads {
            item.pause()
        }
    }

    func makeIterator() -> IndexingIterator<[DownloadItem]> {
        return downloads.makeIterator()
    }

    func addItem(downloadItem: DownloadItem) {
        downloads.append(downloadItem)
    }

}
