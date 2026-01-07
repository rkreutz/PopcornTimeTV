//
//  YoutubeApi.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 04.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation

// https://github.com/yt-dlp/yt-dlp/blob/master/yt_dlp/extractor/youtube.py
class YoutubeApi {
    struct Video: Decodable {
        struct Streaming: Decodable {
            struct Formats: Decodable {
                var url: URL
                var qualityLabel: String? // only for video tracks
                var width: Int?
            }
            var formats: [Formats]?
            var hlsManifestUrl: URL?
        }
        
        var streamingData: Streaming
    }
    
    class func getVideo(id: String) async throws -> Video {
        let body = """
            {
             "context": {
               "client": {
                    "clientName": "IOS",
                    "clientVersion": "20.10.4",
                    "deviceMake": "Apple",
                    "deviceModel": "iPhone16,2",
                    "userAgent": "com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)",
                    "osName": "iPhone",
                    "osVersion": "18.3.2.22D82"
               },
               "user": {
                    "lockedSafetyMode": false
               },
               "request":{
                    "useSsl":true,
                    "internalExperimentFlags":[],
                    "consistencyTokenJars":[]
               }
              },
              "videoId": "\(id)",
              "playbackContext":{
                  "contentPlaybackContext":{
                     "vis":0,
                     "splay":false,
                     "autoCaptionsDefaultOn":false,
                     "autonavState":"STATE_NONE",
                     "html5Preference":"HTML5_PREF_WANTS",
                     "lactMilliseconds":"-1"
                  }
               },
               "racyCheckOk":false,
               "contentCheckOk":false
            }
            """
        let url = URL(string: "https://www.youtube.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let video = try JSONDecoder().decode(Video.self, from: data)
        return video
    }
}
