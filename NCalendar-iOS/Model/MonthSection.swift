//
//  CalendarModels.swift
//  NCalendar-iOS
//
//  Created by namdghyun on 10/4/24.
//

import Foundation
import RxDataSources

struct MonthSection {
    var month: Date // 해당 월의 첫날
    var items: [DayItem]
}

extension MonthSection: SectionModelType {
    init(original: MonthSection, items: [DayItem]) {
        self = original
        self.items = items
    }
}


