//
//  TrackTableViewCell.swift
//  ExURLSession
//
//  Created by 김종권 on 2021/10/25.
//

import UIKit

protocol TrackTableViewCellDelegate: AnyObject {
    func didTapPauseButton(_ cell: TrackTableViewCell)
    func didTapResumeButton(_ cell: TrackTableViewCell)
    func didTapCancelButton(_ cell: TrackTableViewCell)
    func didTapDownloadButton(_ cell: TrackTableViewCell)
}

class TrackTableViewCell: UITableViewCell {

    weak var delegate: TrackTableViewCellDelegate?

    struct Model {
        let track: Track
        let downloaded: Bool
        let download: Download?
    }

    var model: Model? = nil {
        didSet { bind() }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20.0, weight: .bold)
        return label
    }()

    private lazy var supplementLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16.0, weight: .bold)
        return label
    }()

    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .lightGray
        view.progressTintColor = .systemBlue
        view.progress = 0.0
        return view
    }()

    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Download", for: .normal)
        button.addTarget(self, action: #selector(didTapDownloadButton), for: .touchUpInside)
        return button
    }()

    private lazy var pauseButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Pause", for: .normal)
        button.addTarget(self, action: #selector(didTapPauseOrResumeButton), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()

    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = .lightGray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) is not implemented")
    }

    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(supplementLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(downloadButton)
        contentView.addSubview(pauseButton)
        contentView.addSubview(cancelButton)
        contentView.addSubview(progressLabel)
    }

    private func makeConstraints() {
        [titleLabel,
         supplementLabel,
         progressView,
         downloadButton,
         pauseButton,
         cancelButton,
         progressLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let rightSpaceSize = cancelButton.intrinsicContentSize.width + pauseButton.intrinsicContentSize.width + 40
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -rightSpaceSize),

            supplementLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            supplementLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            supplementLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -rightSpaceSize),

            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -rightSpaceSize),
            progressView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cancelButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            pauseButton.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -12),
            pauseButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            progressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    @objc private func didTapDownloadButton() {
        delegate?.didTapDownloadButton(self)
    }

    @objc private func didTapCancelButton() {
        delegate?.didTapCancelButton(self)
    }

    @objc private func didTapPauseOrResumeButton() {
        if pauseButton.titleLabel?.text == "Pause" {
            delegate?.didTapPauseButton(self)
        } else {
            delegate?.didTapResumeButton(self)
        }
    }

    private func bind() {
        titleLabel.text = model?.track.name
        supplementLabel.text = model?.track.artist

        var showDownloadControls = false
        if let download = model?.download {
            showDownloadControls = true
            let title = download.isDownloading ? "Pause" : "Resume"
            pauseButton.setTitle(title, for: .normal)
        }

        pauseButton.isHidden = !showDownloadControls
        cancelButton.isHidden = !showDownloadControls
        progressView.isHidden = !showDownloadControls

        selectionStyle = model?.downloaded == true ? .gray : .none
        downloadButton.isHidden = model?.downloaded == true || showDownloadControls
    }

    func updateProgressDisplay(_ progress: Float, _ totalSize: String) {
        progressView.setProgress(progress, animated: true)
        /// 32.5% of 100
        /// %@ - string value and for many more.
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
}
