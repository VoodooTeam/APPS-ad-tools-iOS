//
//  VoodooGDPRService.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 30/05/2024.
//

import Foundation

final class GDPRService {
    static let shared = GDPRService()

    private init() {}

    func fetchConfig(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://adservice.google.com/getconfig/pubvendors") else {
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let gdpr = json["gdpr"] as? Bool {
                    completion(gdpr)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }

        task.resume()
    }
}
