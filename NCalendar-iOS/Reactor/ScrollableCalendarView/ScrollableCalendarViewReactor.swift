//
//  ScrollableCalendarViewReactor.swift
//  NCalendar-iOS
//
//  Created by namdghyun on 10/4/24.
//

import UIKit
import ReactorKit

final class ScrollableCalendarViewReactor: Reactor {
    enum Action {
        case viewDidLoad
        case didSelectDate(IndexPath)
    }
    
    enum Mutation {
        case setMonthSections([MonthSection])
        case setSelectedDate(Date?)
    }
    
    struct State {
        var monthSections: [MonthSection] = []
        var selectedDate: Date?
        var currentDate: Date = Date()
    }
    
    let initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            // 뷰가 로드되면 월별 섹션 데이터 생성
            return Observable.just(Mutation.setMonthSections(generateMonthSections()))
        case .didSelectDate(let indexPath):
            // 날짜가 선택되면 해당 날짜를 상태에 반영하고 로그 출력
            #warning("DayViewController로 이동하는 로직 구현 필요")
            guard let date = currentState.monthSections[indexPath.section].items[indexPath.item].date else {
                return .empty()
            }
            return Observable.concat([
                Observable.just(Mutation.setSelectedDate(date)),
                Observable.create { observer in
                    print("Selected date: \(date.toString(dateFormat: "YYYY-MM-dd"))")
                    observer.onCompleted()
                    return Disposables.create()
                }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setMonthSections(let sections):
            newState.monthSections = sections
        case .setSelectedDate(let date):
            newState.selectedDate = date
        }
        return newState
    }
    
    // MARK: - Private Methods
    // 월별 섹션 데이터를 생성하는 메서드
    private func generateMonthSections() -> [MonthSection] {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // 현재 월을 기준으로 전후 12개월의 데이터 생성
        return (-12...12).map { monthOffset in
            guard let monthDate = calendar.date(byAdding: .month, value: monthOffset, to: currentDate) else {
                fatalError("Failed to create date")
            }
            
            let days = daysInMonth(monthDate)
            return MonthSection(month: monthDate, items: days)
        }
    }
    
    // 특정 월의 일별 데이터를 생성하는 메서드
    private func daysInMonth(_ date: Date) -> [DayItem] {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        let monthEnd = calendar.date(byAdding: .day, value: -1, to: nextMonth)!
        
        let numberOfDaysInMonth = calendar.component(.day, from: monthEnd)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        
        var days: [DayItem] = []
        
        // 월의 시작 요일 이전의 빈 날짜 추가
        for _ in 1..<firstWeekday {
            days.append(DayItem(date: nil, isSelectable: false, isToday: false, isSelected: false, isCurrentMonth: false))
        }
        
        let today = calendar.startOfDay(for: Date())
        // 월의 각 날짜에 대한 DayItem 생성
        for day in 1...numberOfDaysInMonth {
            let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart)!
            days.append(DayItem(
                date: date,
                isSelectable: true,
                isToday: calendar.isDate(date, inSameDayAs: today),
                isSelected: false,
                isCurrentMonth: true
            ))
        }
        
        return days
    }
}
