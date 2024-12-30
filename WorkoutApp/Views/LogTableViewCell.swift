//
//  LogTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/17/24.
//

import UIKit

class LogTableViewCell: UITableViewCell {
    static let reuseIdentifier = "LogTableViewCell"
    
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let workoutLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    private let exercisesLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 3
        return label
    }()
    
    private let dateVStackView: UIStackView = {
        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.alignment = .center
        return vstack
    }()
    
    private let workoutVStackView: UIStackView = {
        let vstack = UIStackView()
        vstack.axis = .vertical
        return vstack
    }()
    
    private let containerHStackView: UIStackView = {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.alignment = .top
        hstack.spacing = 8
        hstack.translatesAutoresizingMaskIntoConstraints = false
        return hstack
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator

        dateVStackView.addArrangedSubview(weekdayLabel)
        dateVStackView.addArrangedSubview(dayLabel)

        workoutVStackView.addArrangedSubview(workoutLabel)
        workoutVStackView.addArrangedSubview(exercisesLabel)
        
        containerHStackView.addArrangedSubview(dateVStackView)
        containerHStackView.addArrangedSubview(workoutVStackView)
        
        contentView.addSubview(containerHStackView)
        
        NSLayoutConstraint.activate([
            dateVStackView.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            containerHStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerHStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerHStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16), // extra to push dateview
            containerHStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with workout: Workout) {
        guard let createdAt = workout.createdAt else { return }
        let exercises = workout.getExercises()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        weekdayLabel.text = dateFormatter.string(from: createdAt)
        dayLabel.text = "\(Calendar.current.component(.day, from: createdAt))"
        workoutLabel.text = workout.title
        exercisesLabel.text = exercises
            .map { 
                let bestExerciseSet = ($0.getExerciseSets()).max(by: { Float($0.weight)! < Float($1.weight)!  })!
                let title = bestExerciseSet.exercise?.name ?? ""
                let sets = $0.getExerciseSets().count
                let reps = bestExerciseSet.reps
                let weight = bestExerciseSet.weightString
                return "\(sets)x\(reps) \(title) - \(weight) \(Settings.shared.weightUnit.rawValue)"
            }
            .joined(separator: "\n")
    }
}

