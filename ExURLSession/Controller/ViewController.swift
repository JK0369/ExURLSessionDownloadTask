//
//  ViewController.swift
//  ExURLSession
//
//  Created by 김종권 on 2021/10/24.
//

import UIKit

class ViewController: UIViewController {
    
    let urlSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var tracks = [Track]()
    let downloadService = DownloadService()
    lazy var downloadURLSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    @IBOutlet weak var tableView: UITableView!

    // 저장할 곳
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        initDownloadService()
        setupSearchController()
        setupTableView()
    }

    private func setupViews() {
        title = "iOS 앱 개발 알아가기"
    }

    private func initDownloadService() {
        downloadService.urlSession = downloadURLSession
    }

    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search keyword, Tailor swift, json mralz, ..."
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func getSearchResults(keyword: String, completion: ((Result<[Track], Error>) -> Void)? = nil) {
        /// 중복 작업을 피하기 위해서 기존 task에 대해서 진행중인 부분이 있으면 cancel 후 진행
        dataTask?.cancel()

        guard var urlComponents = URLComponents(string: "https://itunes.apple.com/search") else { return }
        urlComponents.query = "media=music&entity=song&term=\(keyword)"
        guard let url = urlComponents.url else { return }

        dataTask = urlSession.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            defer { self?.dataTask = nil }
            guard let data = data else {
                if let error = error {
                    completion?(.failure(error))
                }
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                let jsonDecoder = JSONDecoder()
                do {
                    let track = try jsonDecoder.decode(TrackResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion?(.success(track.toDomain))
                    }
                } catch {
                    completion?(.failure(error))
                }
            }
        })

        /// 모든 task는 일시정지(suspended)상태로 시작하므로 resume() 선언하여 진행
        dataTask?.resume()
    }

    private func setupTableView() {
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: "TrackTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func reloadData(with newTracks: [Track]) {
        tracks = newTracks
        tableView.reloadData()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getSearchResults(keyword: searchBar.text ?? "") { [weak self] result in
            switch result {
            case .success(let responseData):
                self?.reloadData(with: responseData)
            case .failure(let error):
                print(error)
            }
        }
    }
}

// searchController.searchBar.delegate = self
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackTableViewCell", for: indexPath) as! TrackTableViewCell
        let track = tracks[indexPath.row]
        cell.model = .init(track: track, downloaded: track.downloaded, download: downloadService.activeDownloads[track.previewURL])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}

extension ViewController: TrackTableViewCellDelegate {
    func didTapDownloadButton(_ cell: TrackTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let track = tracks[indexPath.row]
        downloadService.startDownload(track)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func didTapPauseButton(_ cell: TrackTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let track = tracks[indexPath.row]
        downloadService.pauseDownload(track)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func didTapResumeButton(_ cell: TrackTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let track = tracks[indexPath.row]
        downloadService.resumeDownload(track)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func didTapCancelButton(_ cell: TrackTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let track = tracks[indexPath.row]
        downloadService.cancelDownload(track)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
