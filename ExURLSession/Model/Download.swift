//
//  Download.swift
//  ExURLSession
//
//  Created by 김종권 on 2021/10/25.
//

import Foundation

class Download {

    var track: Track
    init(track: Track) {
        self.track = track
    }

    /// 각 URL마다 하나의 task를 가지고 있고 이 task를 통해서 download, pause, resume, cancel 호출 (Delegate 위임을 외부에서 해야하므로, 생성자를 ViewController에서 만들어서 이곳에 주입)
    var task: URLSessionDownloadTask?
    /// view에서 isDownloading 플래그값을 보고 버튼을 Pause로 할지, Resume으로 할지 정할 때 사용 (값 set은 DownloadService에서 설정)
    var isDownloading = false
    /// 사용자가 다운로드 일시 중지한 경우(suspended) 생성된 Data 저장
    var resumeData: Data?
    /// progressView에서 사용될 progress 정도 저장
    var progress: Float = 0.0
}
