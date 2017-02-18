//
//  ViewController.swift
//  SYCPrototype
//

import Cocoa

class ViewController: NSViewController, NSWindowDelegate {

    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var urlTextField: NSTextField!

    let downloadController = DownloadController()
    var updateTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        self.view.window?.delegate = self
    }

    override func viewWillDisappear() {
        for item in downloadController {
            item.pause()
        }

        self.updateTimer?.invalidate()
    }

    private func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 170.0, height: 60.0)
        flowLayout.sectionInset = EdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 10.0
        collectionView.collectionViewLayout = flowLayout
        view.wantsLayer = true

        // refreshing for showing current progress & state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateCollectionView), userInfo: nil, repeats: true)
            self.updateTimer?.fire()
        }
    }

    func updateCollectionView() {
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.reloadData()
        //}
    }

    @IBAction func onDownloadClick(_ sender: AnyObject) {
        if !urlTextField.stringValue.isEmpty {
            //starts a new download task with identifier
            downloadController.startDownloading(identifier: urlTextField.stringValue)
            updateCollectionView()
        }
    }
}

extension ViewController: NSCollectionViewDataSource {

    private func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collections \(downloadController.count)")
        return downloadController.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath as IndexPath)

        guard let collectionViewItem = item as? CollectionViewItem else {
            return item
        }

        let downloadTitle = downloadController[indexPath.item]
        collectionViewItem.item = downloadTitle
        collectionViewItem.itemActionButton.tag = indexPath.item
        collectionViewItem.itemActionButton.target = self
        collectionViewItem.itemActionButton.action = #selector(self.onClick(sender:))

        return item
    }

    // on item action button click
    @objc(takesAIntArgument:)
    func onClick(sender: NSButton) {
        print("onclick = \(sender.tag)")

        //PAUSE/RESUME
        if downloadController[sender.tag].state == .IN_PROGRESS {
            downloadController[sender.tag].pause()
        } else {
            downloadController[sender.tag].resume()
        }

        self.updateCollectionView()
    }

}
    


