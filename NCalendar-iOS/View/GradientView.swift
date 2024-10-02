//
//  GradientView.swift
//  NCalendar-iOS
//
//  Created by namdghyun on 10/3/24.
//

import UIKit

/// 뷰의 상단 및 하단에서 시스템 배경색으로 페이드되는 뷰
class GradientView: UIView {
    
    let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupGradient()
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupGradient()
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupGradient() {
        gradientLayer.frame = self.bounds
        // 여기에 다섯 가지 색상을 지정하여 그라데이션을 다섯 개의 밴드로 분할
        // 이렇게 하면 캘린더가 위쪽과 아래쪽 가장자리에서 페이드되어 3D로 표시
        gradientLayer.colors = [UIColor.systemBackground.cgColor,
                                UIColor.systemBackground.withAlphaComponent(0).cgColor,
                                UIColor.systemBackground.withAlphaComponent(0).cgColor,
                                UIColor.systemBackground.withAlphaComponent(0).cgColor,
                                UIColor.systemBackground.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradient()
    }
}

