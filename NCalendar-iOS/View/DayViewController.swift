//
//  DayViewController.swift
//  NCalendar-iOS
//
//  Created by namdghyun on 10/3/24.
//

import UIKit
import SnapKit

class DayViewController: UIViewController {
    var date: Date?
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        updateTitle()
    }
    
    private func startTimer() {
        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    private func updateTime() {
        timeLabel.text = Date().toString(dateFormat: "HH시 mm분 ss초")
    }
    
    private func updateTitle() {
        guard let date = date else {
            title = "No date selected"
            return
        }
        
        title = date.toString(dateFormat: "YYYY년 MMMM월 dd일")
    }
}
