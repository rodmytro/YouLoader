//
//  ViewController.swift
//  SYCPrototype
//

import Cocoa

class ViewController: NSViewController, NSWindowDelegate {

    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var urlTextField: NSTextField!

    let downloadController = DownloadController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        self.view.window?.delegate = self
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func windowShouldClose(_ sender: Any) {
        //NSApplication.shared().terminate(self)
        //TODO
        downloadController[0].pause()
    }

    private func configureCollectionView() {
        // 1
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 170.0, height: 60.0)
        flowLayout.sectionInset = EdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 10.0
        collectionView.collectionViewLayout = flowLayout
        // 2
        view.wantsLayer = true
        // 3
//        collectionView.layer?.backgroundColor = NSColor.black.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            let helloWorldTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: Selector("loadDownloads"), userInfo: nil, repeats: true)
            
            helloWorldTimer.fire()
        }

    }

    func loadDownloads() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.reloadData()
        }
    }

    @IBAction func onDownloadClick(_ sender: AnyObject) {
        if !urlTextField.stringValue.isEmpty {
            downloadController.startDownloading(identifier: urlTextField.stringValue)
            loadDownloads()
        }
    }
}

extension ViewController: NSCollectionViewDataSource {

    // 1
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return 2
    }

    // 2
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collections \(downloadController.count)")
        return downloadController.count
    }

    // 3
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        // 4
        let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath as IndexPath)

        print("item 1 = \(item.className)")

        guard let collectionViewItem = item as? CollectionViewItem else {
            return item
        }

        // 5

        let downloadTitle = downloadController[indexPath.item]
        collectionViewItem.item = downloadTitle
        collectionViewItem.itemActionButton.tag = indexPath.item
        collectionViewItem.itemActionButton.target = self
        collectionViewItem.itemActionButton.action = #selector(self.onClick(sender:))
        print("item 2 = \(downloadTitle)")

        return item
    }
    
    @objc(takesAIntArgument:)
    func onClick(sender: NSButton) {
        print("onclick = \(sender.tag)")
        
        if downloadController[sender.tag].state == .IN_PROGRESS {
            downloadController[sender.tag].pause()
        } else {
            downloadController[sender.tag].resume()
        }
    }

}


extension ViewController: NSCollectionViewDelegate {
    // 1
    func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        
        
        print("downloading")
        // 2
        guard let indexPath = indexPaths.first else {
            return
        }
        // 3
        guard let item = collectionView.item(at: indexPath as IndexPath) else {
            return
        }

        //OnCLick
        print("downloading from \(item)")
    }

    func collectionView(_ collectionView: NSCollectionView,
                        didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        print("downloading")
        
        guard let indexPath = indexPaths.first else {
            return
        }
        guard let item = collectionView.item(at: indexPath as IndexPath) else {
            return
        }

        //OnCLick
        print("downloading from \(item)")
    }

}
    


