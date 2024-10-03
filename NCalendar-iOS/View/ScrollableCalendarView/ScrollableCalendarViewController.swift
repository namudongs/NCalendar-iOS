//
//  ScrollableCalendarViewController.swift
//  NCalendar-iOS
//
//  Created by namdghyun on 10/3/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxDataSources

final class ScrollableCalendarViewController: UIViewController, View {
    typealias Reactor = ScrollableCalendarViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    // 각 날짜 셀의 높이
    let cellHeight: CGFloat = 64
    // 월 섹션 헤더의 높이
    let headerHeight: CGFloat = 20
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ScrollableCalendarViewCell.self, forCellWithReuseIdentifier: "dayCell")
        return collectionView
    }()
    
    private lazy var weekdayHeader: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        
        let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
        for weekday in weekdays {
            let label = UILabel()
            label.text = weekday
            label.textAlignment = .center
            label.textColor = .label
            label.font = .systemFont(ofSize: 18, weight: .medium)
            stackView.addArrangedSubview(label)
            
            label.snp.makeConstraints { make in
                make.width.height.equalTo(44)
            }
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Binding
    // 뷰 컨트롤러와 리액터 사이의 데이터 바인딩 설정
    func bind(reactor: Reactor) {
        // Action
        // 뷰가 로드되었음을 리액터에 알림
        reactor.action.onNext(.viewDidLoad)
        
        // 날짜 선택 액션을 리액터에 바인딩
        collectionView.rx.itemSelected
            .map { Reactor.Action.didSelectDate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        // 월별 섹션 데이터를 컬렉션 뷰에 바인딩
        reactor.state.map { $0.monthSections }
            .bind(to: collectionView.rx.items(dataSource: createDataSource()))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        title = "캘린더"
        view.backgroundColor = .systemBackground
        view.addSubview(weekdayHeader)
        view.addSubview(collectionView)
        
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
        
        // 컬렉션 뷰 셀 크기 설정
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: (view.bounds.width - 64) / 7, height: cellHeight)
        }
    }
    
    // RxDataSources를 사용한 데이터 소스 생성
    private func createDataSource() -> RxCollectionViewSectionedReloadDataSource<MonthSection> {
        return RxCollectionViewSectionedReloadDataSource<MonthSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as! ScrollableCalendarViewCell
                let reactor = ScrollableCalendarViewCellReactor(dayItem: item)
                cell.reactor = reactor
                return cell
            }
        )
    }
    
    // 현재 날짜로 스크롤하는 메서드 (구현 필요)
    private func scrollToCurrentDate(_ date: Date) {
        #warning("현재 날짜로 스크롤되는 로직 구현")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
// 컬렉션 뷰 레이아웃 관련 메서드 구현
extension ScrollableCalendarViewController: UICollectionViewDelegateFlowLayout {
    // 각 아이템(날짜 셀)의 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width) / 7
        return CGSize(width: width, height: cellHeight)
    }
    
    // 각 섹션(월) 헤더의 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: headerHeight)
    }
}
