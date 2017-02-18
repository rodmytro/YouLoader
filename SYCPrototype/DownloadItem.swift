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
        self.progress = 0

        self.dataCompleted = Data()
        self.retryCounter = 0
        self.totalDataSize = 0

        self.state = .IN_PROGRESS

        initUrl()
    }

    func start() {
        start(headers: [:])
    }

    func start(headers: HTTPHeaders) {
        state = .IN_PROGRESS

        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 10

        request = manager.request(url!, headers: headers)
        .downloadProgress(queue: concurrentDownloadQueue) {
            progress in
            print("progress \(progress.fractionCompleted)")

            self.progress = progress.fractionCompleted

            if self.totalDataSize == 0 {
                self.totalDataSize = progress.totalUnitCount
            }

            self.retryCounter = 0
        }
        .responseData {
            response in

            switch response.result {
            case .success:
                self.state = .FINISHED
                self.dataCompleted.append(response.data!)

                print("SUCCESS total size = \(self.dataCompleted.count)")
                FileUtils().writeDataToFile(data: self.dataCompleted)

            case .failure(let error):
                self.state = .RETRY
                self.dataCompleted.append(response.data!)

                DispatchQueue.main.asyncAfter(deadline: .now() + self.SECONDS_BETWEEN_RETRY) {
                    self.retry()
                }

                print("Code: \(response.response?.statusCode)")
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

            let bytesRange = "bytes=\(dataCompleted.count)-\(totalDataSize)"
            let headers: HTTPHeaders = ["Range": bytesRange]
            print(bytesRange)

            start(headers: headers)

        } else {
            state = .FAILED
        }
    }

    func initUrl() {
        XCDYouTubeClient.default().getVideoWithIdentifier(identifier) {
            (video: XCDYouTubeVideo?, error: Error?) in
            if let video = video {
                self.url = (video.streamURLs.first?.value)!

                self.start()
            }
        }
    }

}
