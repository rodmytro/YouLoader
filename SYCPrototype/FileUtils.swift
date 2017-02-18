//
//  FileUtils.swift
//  SYCPrototype
//

import Foundation
import Cocoa

class FileUtils {

    let DEFAULT_FILE_NAME = "You-Loader.mp4"
    
    func writeDataToFile(data: Data) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        let fileUrl = documentsUrl.appendingPathComponent(DEFAULT_FILE_NAME)

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
