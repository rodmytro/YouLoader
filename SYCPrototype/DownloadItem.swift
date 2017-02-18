//
//  DownloadItem.swift
//  SYCPrototype


import Alamofire
import Foundation
import XCDYouTubeKit

class DownloadItem {
    let MAX_RETRY_ITERATIONS = 5
    let SECONDS_BETWEEN_RETRY = 5.0

    let concurrentDownloadQueue =
    DispatchQueue(
            label: "concurrentDownloadQueue",
            qos: .utility,
            attributes: .concurrent)

    let manager = Alamofire.SessionManager.default

    enum State {
        case IN_PROGRESS
        case PAUSED
        case RETRY
        case FAILED
        case FINISHED
    }

    var identifier: String
    var url: URL?
    var state: State
    var progress: Double

    var dataCompleted: Data
    var retryCounter: Int
    var totalDataSize: Int64


    var request: Alamofire.Request?

    init(identifier: String) {
        self.identifier = identifier
        self.dataCompleted = Data()
        self.retryCounter = 0
        self.totalDataSize = 0

        self.progress = 0
        self.state = .PAUSED

        self.manager.session.configuration.timeoutIntervalForRequest = 15

        initUrl()
    }

    func start() {
        start(headers: [:])
    }

    func start(headers: HTTPHeaders) {
        state = .IN_PROGRESS

        request = manager.request(url!, headers: headers)
        .downloadProgress(queue: concurrentDownloadQueue) {
            progress in
            print("progress \(progress.fractionCompleted)")

            self.progress = progress.fractionCompleted

            // saves total size of downloaded item - for resuming
            if self.totalDataSize == 0 {
                self.totalDataSize = progress.totalUnitCount
            }

            // if in this block - downloading is in progress
            // so clears retry counter
            self.retryCounter = 0
        }
        .responseData {
            response in

            //adds now downloaded part to previous
            //if first - previous = 0
            self.dataCompleted.append(response.data!)

            switch response.result {
            case .success:
                self.state = .FINISHED
                print("SUCCESS total size = \(self.dataCompleted.count)")

                FileUtils().writeDataToFile(data: self.dataCompleted)

            case .failure(let error):
                self.state = .RETRY
                print("Error: \(error)")

                //retrying download after SECONDS_BETWEEN_RETRY
                DispatchQueue.main.asyncAfter(deadline: .now() + self.SECONDS_BETWEEN_RETRY) {
                    self.retry()
                }
            }
        }
    }

    func pause() {
        state = .PAUSED
        request?.suspend()
    }

    func resume() {
        state = .IN_PROGRESS
        request?.resume()
    }

    func cancel() {
        state = .FAILED
        request?.cancel()
    }

    func retry() {
        if retryCounter < MAX_RETRY_ITERATIONS {
            self.state = .RETRY

            retryCounter += 1

            //creating a retry header
            let bytesRange = "bytes=\(dataCompleted.count)-\(totalDataSize)"
            let headers: HTTPHeaders = ["Range": bytesRange]
            print(bytesRange)

            start(headers: headers)
        } else {
            state = .FAILED
        }
    }

    func initUrl() {
        //gets URL from identifier and starts downloading
        XCDYouTubeClient.default().getVideoWithIdentifier(identifier) {
            (video: XCDYouTubeVideo?, error: Error?) in
            if let video = video {
                self.url = (video.streamURLs.first?.value)!

                self.start()
            } else {
                self.state = .FAILED
                print("wrong identifier")
            }
        }
    }

}
