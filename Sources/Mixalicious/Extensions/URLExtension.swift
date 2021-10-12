import Foundation

private let fileManager = FileManager.default

extension URL {
    /// Obtains folder to store asset. If folder does not exist, will create it
    /// - Parameter folderName: String containing folder name
    /// - Returns: URL of folder, or nil if it could not be created
    private static func getFolder(folderName: String) -> URL? {
        // swiftlint:disable force_unwrapping
        let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                 in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(folderName)

        if !fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.createDirectory(atPath: fileURL.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                assertionFailure(error.localizedDescription)

                return nil
            }
        }

        return fileURL
    }

    /// Initializes a URL for asset
    /// - Parameter mediaType: MediaType of asset. This provides folder name and extension
    init?(mediaType: MediaType) {
        guard let folder = URL.getFolder(folderName: mediaType.folderName) else {
            return nil
        }

        let fileName = String(UUID().uuidString.prefix(8))

        let filePath = folder
            .appendingPathComponent(fileName)
            .appendingPathExtension(mediaType.fileExtension)
            .path

        self.init(fileURLWithPath: filePath)
    }

    /// Removes all files in provided MediaType's folder. Used for testing purposes
    /// - Parameter mediaType: MediaType of files to remove
    static func removeAllFiles(mediaType: MediaType) {
        guard let folder = URL.getFolder(folderName: mediaType.folderName) else {
            return
        }

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: folder.path)
            try contents.forEach { componentPath in
                let filePath = folder.appendingPathComponent(componentPath).path
                try fileManager.removeItem(atPath: filePath)
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    /// Removes folder of provided MediaType. Used for testing purposes
    /// - Parameter mediaType: MediaType of folder to remove
    static func removeFolder(mediaType: MediaType) {
        // swiftlint:disable force_unwrapping
        let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                 in: .userDomainMask).first!
        let folderPath = documentDirectory.appendingPathComponent(mediaType.folderName).path
        if fileManager.fileExists(atPath: folderPath) {
            do {
                try fileManager.removeItem(atPath: folderPath)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}
