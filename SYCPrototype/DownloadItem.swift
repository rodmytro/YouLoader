//
//  DownloadItem.swift
//  SYCPrototype


import Alamofire
import Foundation

class DownloadItem {
    let concurrentDownloadQueue =
    DispatchQueue(
            label: "concurrentDownloadQueue",
            qos: .utility,
            attributes: .concurrent)

    enum State {
        case IN_PROGRESS
        case PAUSED
        case FAILED
        case FINISHED
    }

    var url: URL
    var name: String
    var state: State
    var progress: Double

    //var bytesCompleted: Int64
    var dataCompleted: Data
    var retryCounter: Int


    var request: Alamofire.Request?

    init(url: URL, name: String) {
        self.url = url
        self.name = name
        self.progress = 0

        //self.bytesCompleted = 0
        self.dataCompleted = Data()
        self.retryCounter = 0

        self.state = .IN_PROGRESS
    }

    func start() {
        start(parameters: [:])
    }

    func start(parameters: Parameters) {
        let manager = Alamofire.SessionManager.default
        //manager.session.configuration.timeoutIntervalForRequest = 10

        request = manager.request(url, parameters: parameters)
        .downloadProgress(queue: concurrentDownloadQueue) {
            progress in
            self.progress = progress.fractionCompleted
            //self.bytesCompleted = progress.completedUnitCount
        }
        .responseData {
            response in

            switch response.result {
            case .success:
                self.state = .FINISHED
                print("SUCCESS size = \(response.data?.count)")
            case .failure(let error):
                self.dataCompleted.append(response.data!)
                self.state = .FAILED

                print("Code: \(response.response?.statusCode)")
                print("Completed: \(self.dataCompleted.count) bytes")
            }
        }
    }

    func pause() {
        state = .PAUSED
        request?.suspend()
    }

    func resume() {
        if (state == .PAUSED) {
            state = .IN_PROGRESS
            request?.resume()
        } else if (state == .FAILED) {
            let parameters: Parameters = ["Bytes": dataCompleted.count]
            start(parameters: parameters)
        }
    }

    func cancel() {
        state = .FAILED
        request?.cancel()
    }

    func retry() {
        retryCounter += 1
    }

}
