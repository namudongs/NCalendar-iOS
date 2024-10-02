//
//  ScrollableCalendarViewCell.swift
//  NCalendar-iOS
//
//  Created by namdghyun on 10/3/24.
//

import UIKit
import SnapKit

class ScrollableCalendarViewCell: UICollectionViewCell {
    var date: Date?
    private let numberLabel = UILabel()
    private let topBorder = UIView()
    private let monthHeaderLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        contentView.addSubview(numberLabel)
        addSubview(topBorder)
        addSubview(monthHeaderLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        topBorder.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(-5)
            make.trailing.equalToSuperview().offset(5)
            make.height.equalTo(0.5)
        }
        topBorder.backgroundColor = .systemGray5

        monthHeaderLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(topBorder.snp.top).offset(-2)
        }
        monthHeaderLabel.font = .systemFont(ofSize: 12, weight: .bold)
        monthHeaderLabel.textColor = .systemGray
    }

    func configure(with date: Date?, isFirstDayOfMonth: Bool) {
        self.date = date
        numberLabel.text = date.map { "\(Calendar.current.component(.day, from: $0))" } ?? ""
        topBorder.isHidden = date == nil

        if isFirstDayOfMonth, let date = date {
            monthHeaderLabel.text = date.toString(dateFormat: "MMM")
            monthHeaderLabel.isHidden = false
        } else {
            monthHeaderLabel.isHidden = true
        }
    }

    func setHighlighted(_ highlighted: Bool) {
        numberLabel.textColor = highlighted ? .systemBlue : .label
        numberLabel.font = .systemFont(ofSize: highlighted ? 18 : 16, weight: highlighted ? .black : .semibold)
    }
}
