//
//  DownloadItem.swift
//  SYCPrototype


import Alamofire
import Foundation

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
        case PAUSE_FAILED
        case RETRY
        case FAILED
        case FINISHED
    }

    var url: URL?
    var state: State
    var progress: Double

    var dataCompleted: Data
    var retryCounter: Int
    var totalDataSize: Int64

    var request: Alamofire.Request?

    init(url: URL) {
        self.url = url
        self.dataCompleted = Data()
        self.retryCounter = 0
        self.totalDataSize = 0

        self.progress = 0
        self.state = .PAUSED

        self.manager.session.configuration.timeoutIntervalForRequest = 5
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
                print("Error: \(error)")

                // after long pause - request timed out error, 
                // so when resume we need to retry download
                if self.state == .PAUSED {
                    self.state = .PAUSE_FAILED
                } else {
                    self.state = .RETRY
                    // retrying download after SECONDS_BETWEEN_RETRY
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.SECONDS_BETWEEN_RETRY) {
                        self.retry()
                    }
                }
            }
        }
    }

    func pause() {
        state = .PAUSED
        request?.suspend()
    }

    func resume() {
        if (state == .PAUSE_FAILED) {
            retry()
        } else {
            request?.resume()
        }

        state = .IN_PROGRESS
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

}
