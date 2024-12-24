//
//  DayTrackView.swift
//  DayTrack
//
//  Created by Марк Райтман on 24.12.2024.
//

import Foundation
import UIKit
import CalendarKit

class DayTrackView: UIView {
    
    // MARK: - Subviews
    let dayView: DayView = {
        let view = DayView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(dayView)
        
        // Constraints to fill the entire view
        NSLayoutConstraint.activate([
            dayView.topAnchor.constraint(equalTo: topAnchor),
            dayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
