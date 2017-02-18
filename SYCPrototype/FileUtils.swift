//

import Foundation
import Cocoa

class FileUtils {

    func writeDataToFile(data: Data) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        let fileUrl = documentsUrl.appendingPathComponent("You-Loader.mp4")

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
