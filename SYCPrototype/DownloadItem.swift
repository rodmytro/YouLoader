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
    
    var request: Alamofire.Request?
    
    init(url: URL, name: String) {
        self.url = url
        self.name = name
        self.progress = 0
        
        self.state = .IN_PROGRESS
    }
    
    func start() {
//        let utilityQueue = DispatchQueue.global(qos: .utility)
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 600
        
        request = manager.request(url)
            .downloadProgress(queue: concurrentDownloadQueue) {
                progress in
                self.progress = progress.fractionCompleted
                print("bytes \(progress.completedUnitCount)")
            }
            .responseData {
                response in
                
                switch response.result {
                case .success:
                    self.state = .FINISHED
                    print("SUCCESS size = \([UInt8] (response.data!))")
                case .failure(let error):
                    self.state = .FAILED
                    print("Code: \(response.response?.statusCode)")
                    print(error)
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
    
}
