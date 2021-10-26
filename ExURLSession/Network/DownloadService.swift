//
//  DownloadService.swift
//  ExURLSession
//
//  Created by 김종권 on 2021/10/25.
//

import Foundation

class DownloadService {

    var urlSession: URLSession!
    var activeDownloads: [URL: Download] = [:]

    /// dataTask의 resume() 호출
    func startDownload(_ track: Track) {
        let download = Download(track: track)
        download.task = urlSession.downloadTask(with: track.previewURL)
        download.task?.resume()
        download.isDownloading = true
        activeDownloads[track.previewURL] = download
    }

    /// dataTask를 cancel 후, 진행중인 data를 임시로 저장
    func pauseDownload(_ track: Track) {
        guard let download = activeDownloads[track.previewURL] else { return }
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { data in
                download.resumeData = data
            })
            download.isDownloading = false
        }
    }

    /// dataTask를 cancel()
    func cancelDownload(_ track: Track) {
        if let download = activeDownloads[track.previewURL] {
            download.task?.cancel()
            activeDownloads[track.previewURL] = nil
        }
    }

    /// cancel에서 저장해둔 data를 다시 불러와서 resume (없는 경우 새로 생성)
    func resumeDownload(_ track: Track) {
        guard let download = activeDownloads[track.previewURL] else { return }
        if let resumeData = download.resumeData {
            download.task = urlSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = urlSession.downloadTask(with: track.previewURL)
        }
        download.task?.resume()
        download.isDownloading = true
    }

}
