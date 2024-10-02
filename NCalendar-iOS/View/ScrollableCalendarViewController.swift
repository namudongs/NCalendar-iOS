//
//  ScrollableCalendarViewController.swift
//  NCalendar-iOS
//
//  Created by namdghyun on 10/3/24.
//

import UIKit
import SnapKit

class ScrollableCalendarViewController: UIViewController {
    
    // MARK: - Properties
    // 과거 및 미래 달력 범위 설정
    let numberOfPastMonths: Int = 12
    let numberOfFutureMonths: Int = 12
    
    // 셀과 헤더의 높이 설정
    let cellHeight: CGFloat = 64
    let headerHeight: CGFloat = 20
    
    // 현재 달력 객체
    let calendar = Calendar.current
    
    // 사용자가 선택한 날짜를 저장하는 변수
    var selectedDate: Date?
    
    // MARK: - UI Components
    // 달력을 표시할 CollectionView
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0  // 세로 간격을 0으로 설정
        layout.minimumInteritemSpacing = 0  // 가로 간격을 0으로 설정
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear  // 배경을 투명하게 설정
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ScrollableCalendarViewCell.self, forCellWithReuseIdentifier: "calendarCell")
        // 헤더 뷰 등록 코드는 유지
        
        return collectionView
    }()
    
    // 요일을 표시하는 헤더 뷰
    private lazy var weekdayHeader: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        
        // 요일을 가로로 나열하기 위한 스택 뷰
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        
        // 각 요일 레이블 생성 및 스택 뷰에 추가
        let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
        for weekday in weekdays {
            let label = UILabel()
            label.text = weekday
            label.textAlignment = .center
            label.textColor = .black
            label.font = .systemFont(ofSize: 18, weight: .medium)
            stackView.addArrangedSubview(label)
            
            // 각 요일 레이블의 크기 제약 설정
            label.snp.makeConstraints { make in
                make.width.height.equalTo(44)
            }
        }
        
        // 스택 뷰를 헤더 뷰에 추가하고 제약 설정
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    // 그라데이션 효과를 위한 뷰
    private lazy var gradientView: GradientView = {
        let view = GradientView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // 뷰가 나타났을 때 이번 달로 스크롤되는 메서드
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let section = numberOfPastMonths
        let firstDayOfMonth = calendar.date(
            from: DateComponents(year: year, month: month, day: 1)
        )!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
        let middleDay = daysInMonth / 2
        let item = (firstWeekday - 1) + (middleDay - 1)
        
        collectionView.scrollToItem(
            at: IndexPath(item: item, section: section),
            at: .centeredVertically, animated: false
        )
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        title = "캘린더"
        
        view.addSubview(weekdayHeader)
        view.addSubview(collectionView)
        view.addSubview(gradientView)
        
        collectionView.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        weekdayHeader.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(weekdayHeader.snp.bottom)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalTo(collectionView)
        }
    }
    
    // MARK: - Navigation
    private func navigateToDayView(for date: Date) {
        let dayViewController = DayViewController()
        dayViewController.date = date
        
        navigationController?.pushViewController(dayViewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ScrollableCalendarViewController: UICollectionViewDataSource {
    // 섹션 수 반환 (과거 + 미래 + 현재 달)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfPastMonths + numberOfFutureMonths + 1
    }
    
    // 각 섹션의 아이템 수 반환 (해당 월의 일수 + 시작 요일 오프셋)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let indexPath = IndexPath(item: 0, section: section)
        
        let year = self.year(at: indexPath)
        let month = self.month(at: indexPath)
        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        
        // 해당 월의 일수 계산
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
        // 해당 월의 시작 요일 오프셋 계산
        let dayOffset = self.dayOffset(year: year, month: month)
        
        // 총 셀 수 = 일수 + 시작 요일 오프셋
        return daysInMonth + dayOffset
    }
    
    // 각 셀의 기본 내용 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as? ScrollableCalendarViewCell else {
            return UICollectionViewCell()
        }
        
        let year = self.year(at: indexPath)
        let month = self.month(at: indexPath)
        
        if let day = day(at: indexPath) {
            let date = calendar.date(from: DateComponents(calendar: calendar, year: year, month: month, day: day))!
            let isFirstDayOfMonth = day == 1
            cell.configure(with: date, isFirstDayOfMonth: isFirstDayOfMonth)
            
            if calendar.isDateInToday(date) {
                cell.setHighlighted(true)
            } else {
                cell.setHighlighted(false)
            }
        } else {
            cell.configure(with: nil, isFirstDayOfMonth: false)
        }
        
        return cell
    }
    
    // 주어진 indexPath에 해당하는 연도 계산
    private func year(at indexPath: IndexPath) -> Int {
        let shiftedDate = calendar.date(byAdding: .month, value: indexPath.section - numberOfPastMonths, to: Date())!
        let year = calendar.component(.year, from: shiftedDate)
        return year
    }
    
    // 주어진 indexPath에 해당하는 월 계산
    private func month(at indexPath: IndexPath) -> Int {
        let shiftedDate = calendar.date(byAdding: .month, value: indexPath.section - numberOfPastMonths, to: Date())!
        let month = calendar.component(.month, from: shiftedDate)
        return month
    }
    
    // 주어진 indexPath에 해당하는 일 계산
    private func day(at indexPath: IndexPath) -> Int? {
        let year = self.year(at: indexPath)
        let month = self.month(at: indexPath)
        
        // 월의 시작 요일 오프셋을 고려하여 실제 날짜 계산
        let day = indexPath.row - dayOffset(year: year, month: month) + 1
        
        // 1일 이전의 셀은 nil 반환 (이전 달의 날짜)
        guard day >= 1 else {
            return nil
        }
        
        return day
    }
    
    // 주어진 연도와 월의 시작 요일 오프셋 계산
    private func dayOffset(year: Int, month: Int) -> Int {
        // 해당 월의 1일의 요일 계산 (1: 일요일, 2: 월요일, ..., 7: 토요일)
        let firstOfMonthDateComponents = DateComponents(calendar: calendar, year: year, month: month, day:  1)
        let startOfMonth = calendar.date(from: firstOfMonthDateComponents)!
        let dayOffset = calendar.component(.weekday, from: startOfMonth) - 1
        return dayOffset
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ScrollableCalendarViewController: UICollectionViewDelegateFlowLayout {
    // 각 셀의 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7  // 7일로 나누어 셀 너비 계산
        return CGSize(width: width, height: CGFloat(cellHeight))
    }
    
    // 헤더 뷰의 크기 설정
    // 월을 표시하는 부분의 영역 확보, 실제 레이블은 셀에서 표시
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: CGFloat(headerHeight))
    }
}

// MARK: - UICollectionViewDelegate
extension ScrollableCalendarViewController: UICollectionViewDelegate {
    // 셀 선택 시 동작
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ScrollableCalendarViewCell,
              let date = selectedCell.date else {
            return
        }
        
        // 선택된 날짜 저장해 다음 뷰로 전달
        self.selectedDate = date
        navigateToDayView(for: date)
    }
}
