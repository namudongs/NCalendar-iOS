//
//  ScrollableCalendarViewCell.swift
//  NCalendar-iOS
//
//  Created by namdghyun on 10/3/24.
//

import UIKit
import SnapKit
import ReactorKit

final class ScrollableCalendarViewCell: UICollectionViewCell, View {
    typealias Reactor = ScrollableCalendarViewCellReactor

    var disposeBag = DisposeBag()

    // MARK: - UI Components
    private let numberLabel = UILabel()
    private let topBorder = UIView()
    private let monthHeaderLabel = UILabel()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
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

    // MARK: - Binding
    func bind(reactor: Reactor) {
        // State
        // 날짜 숫자 바인딩
        reactor.state.map { $0.dayNumber }
            .bind(to: numberLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 월의 첫 날인지 여부에 따라 월 헤더 레이블 표시/숨김
        reactor.state.map { $0.isFirstDayOfMonth }
            .map { !$0 }
            .bind(to: monthHeaderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 월 이름 바인딩
        reactor.state.map { $0.monthName }
            .bind(to: monthHeaderLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 날짜가 표시 가능한지 여부에 따라 셀 표시/숨김
        reactor.state.map { !$0.isVisible }
            .bind(to: rx.isHidden)
            .disposed(by: disposeBag)
        
        // 날짜가 강조되어야 하는지 여부에 따라 스타일 변경
        reactor.state.map { $0.isHighlighted }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isHighlighted in
                self?.setHighlighted(isHighlighted)
            })
            .disposed(by: disposeBag)
        
        // 현재 월의 날짜인지 여부에 따라 텍스트 색상 변경
        reactor.state.map { $0.isCurrentMonth }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isCurrentMonth in
                self?.numberLabel.textColor = isCurrentMonth ? .label : .systemGray3
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private Methods
    // 날짜 강조 여부에 따라 스타일 변경
    private func setHighlighted(_ highlighted: Bool) {
        numberLabel.textColor = highlighted ? .systemBlue : .label
        numberLabel.font = .systemFont(ofSize: highlighted ? 18 : 16, weight: highlighted ? .black : .semibold)
    }
}
