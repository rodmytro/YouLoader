//
//  FileUtils.swift
//  SYCPrototype
//

import Foundation
import Cocoa

class FileUtils {

    let DEFAULT_FILE_NAME = "You-Loader"
    let MP4 = ".mp4"
    
    private func generateFilename() -> String {
        let date = NSDate()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        let minutes = calendar.component(.minute, from: date as Date)
        let seconds = calendar.component(.second, from: date as Date)

        return DEFAULT_FILE_NAME + String(hour) + String(minutes) + String(seconds) + MP4
    }
    
    func writeDataToFile(data: Data) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        let fileUrl = documentsUrl.appendingPathComponent(generateFilename())

        writeDataToFile(data: data, path: fileUrl!)
    }

    func writeDataToFile(data: Data, path: URL) {
        do {
            try data.write(to: path)
        } catch {
            print("Error writing to file")
        }
    }

}
