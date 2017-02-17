//
//  CollectionViewItem2.swift
//  SYCPrototype
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var itemTitle: NSTextField!
    @IBOutlet weak var itemActionButton: NSButton!

    var item: DownloadItem? {
        didSet {
            guard isViewLoaded else {
                return
            }
            if let item = item {
                setInfo()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }

    func setInfo() {
        if let item = item {
            switch item.state {
            case .IN_PROGRESS:
                itemActionButton.isHidden = false
                itemTitle?.stringValue = "Progress: \(Double(item.progress).toPercents())%"
                itemActionButton?.title = "Pause"
                break
            case .PAUSED:
                itemActionButton.isHidden = false
                itemTitle?.stringValue = "Progress: \(Double(item.progress).toPercents())%"
                itemActionButton?.title = "Resume"
                break
            case .FINISHED:
                itemActionButton.isHidden = true
                itemTitle?.stringValue = "Finished"
            case .FAILED:
                itemActionButton.isHidden = true
                itemTitle?.stringValue = "Failed"
            }
        }
    }
}
