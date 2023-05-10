//
//  URLExt.swift
//  
//
//  Created by vedlai on 5/1/23.
//
#if canImport(UIKit)
import UIKit
extension URL {
    public func downloadImage() async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: self)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponseType
        }
        guard httpResponse.statusCode == 200 else {
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }
        guard let image = UIImage(data: data) else {
            throw ServiceError.unableToGetImageFromURL
        }
        return image
    }

    public func downloadImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: URLRequest(url: self), completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                do {
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw ServiceError.invalidResponseType
                    }
                    guard httpResponse.statusCode == 200 else {
                        throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
                    }
                    guard let data = data, let image = UIImage(data: data) else {
                        throw ServiceError.unableToGetImageFromURL
                    }
                    completion(.success(image))
                } catch {
                    completion(.failure(error))
                }
            }
        })
        task.resume()
    }

    fileprivate enum ServiceError: String, LocalizedError, Sendable {
        case unableToGetImageFromURL
        case invalidResponseType
        public var errorDescription: String? {
            rawValue.localizedCapitalized.camelCaseToWords()
        }
    }

}
#endif
