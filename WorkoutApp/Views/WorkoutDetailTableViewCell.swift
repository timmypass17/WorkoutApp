//
//  WorkoutDetailTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//

import UIKit
import SwiftUI

protocol WorkoutDetailTableViewCellDelegate: AnyObject {
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didUpdateExerciseSet exerciseSet: ExerciseSet)
    // Had to separte func because user typing focus disappears when pressing checkmark (Due to reloadsection)
//    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapCheckmarkForSet exerciseSet: ExerciseSet)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, nextButtonTapped: Bool)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, previousButtonTapped: Bool)
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapSetButton: Bool)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, weightTextDidChange weightText: String)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, repsTextDidChange repsText: String)
}

class WorkoutDetailTableViewCell: UITableViewCell {
    static let reuseIdentifier = "WorkoutDetailCell"
    
//    var workout: Workout!
//    var set: ExerciseSet!
    
    var setButton: UIButton = {
        let button = UIButton()
        button.changesSelectionAsPrimaryAction = true   // make button togglable
        return button
    }()
    
    var previousLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    var weightTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()
    
    var repsTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()
    
    var toolbar: UIToolbar = {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(doneButtonTapped))
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(previousButtonTapped))
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(nextButtonTapped))
        let minusButton = UIBarButtonItem(image: UIImage(systemName: "minus"), style: .plain, target: self, action: #selector(decrement))
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(increment))

        leftButton.tintColor = Settings.shared.accentColor.color
        rightButton.tintColor = Settings.shared.accentColor.color
        minusButton.tintColor = Settings.shared.accentColor.color
        plusButton.tintColor = Settings.shared.accentColor.color

        bar.items = [leftButton, .flexibleSpace(), rightButton, .flexibleSpace(), minusButton, .flexibleSpace(), plusButton, .flexibleSpace(), doneButton]
        bar.sizeToFit()
        return bar
    }()
    
    var container: UIStackView = {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.spacing = 8
        hstack.distribution = .fill
        hstack.translatesAutoresizingMaskIntoConstraints = false
        return hstack
    }()
    

    weak var delegate: WorkoutDetailTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        weightTextField.inputAccessoryView = toolbar
        repsTextField.inputAccessoryView = toolbar
        
        setButton.addAction(didTapCheckmark(), for: .primaryActionTriggered)
        weightTextField.addAction(weightTextFieldDidChange(), for: .editingChanged)
        repsTextField.addAction(repsTextFieldDidChange(), for: .editingChanged)
        
        container.addArrangedSubview(setButton)
        container.addArrangedSubview(previousLabel)
        container.addArrangedSubview(weightTextField)
        container.addArrangedSubview(repsTextField)
        
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
        
        // Percentage width (to stop textfield from expanding)
        NSLayoutConstraint.activate([
            previousLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            weightTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            repsTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(exerciseSet: ExerciseSet) {
        setButton.isSelected = exerciseSet.isComplete
        weightTextField.text = exerciseSet.weight
        repsTextField.text = exerciseSet.reps
        updateSetButton(exerciseSet: exerciseSet)
        previousLabel.text = "-"
    }
    
    func updateSetButton(exerciseSet: ExerciseSet) {
        var config = UIImage.SymbolConfiguration(pointSize: 30)
        let colors: [UIColor] = exerciseSet.isCurrentSet ? [Color.ui.cellNo, Settings.shared.accentColor.color] : [.systemGray, .systemGray]
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: colors))
        setButton.setImage(UIImage(systemName: "\(exerciseSet.index + 1).circle", withConfiguration: config), for: .normal)

        // Selected
        var selectedConfig = UIImage.SymbolConfiguration(pointSize: 30)
        selectedConfig = selectedConfig.applying(UIImage.SymbolConfiguration(paletteColors: [.white, Settings.shared.accentColor.color]))
        setButton.setImage(UIImage(systemName: "\(exerciseSet.index + 1).circle.fill", withConfiguration: selectedConfig), for: .selected)

    }
    
    func didTapCheckmark() -> UIAction {
        return UIAction { [self] _ in
            delegate?.workoutDetailTableViewCell(self, didTapSetButton: true)
        }
    }
    
    func weightTextFieldDidChange() -> UIAction {
        return UIAction { _ in
            self.delegate?.workoutDetailTableViewCell(self, weightTextDidChange: self.weightTextField.text ?? "")
        }
    }
    
    func repsTextFieldDidChange() -> UIAction {
        return UIAction { _ in
            self.delegate?.workoutDetailTableViewCell(self, repsTextDidChange: self.repsTextField.text ?? "")
        }
    }
    
//    func update(with workout: Workout, for indexPath: IndexPath, previousWeights: [(String, String)]) {
//        self.workout = workout
//        let exercise = workout.getExercise(at: indexPath.section)
//        self.set = exercise.getExerciseSet(at: indexPath.row)
//        setButton.isSelected = set.isComplete
//        weightTextField.text = set.weightString
//        repsTextField.text = set.reps
//        
//        // Normal
//        let indexOfCurrentSet = exercise.getExerciseSets().firstIndex { !$0.isComplete } ?? exercise.getExerciseSets().count
//        let isCurrentSet = indexPath.row == indexOfCurrentSet
//        var config = UIImage.SymbolConfiguration(pointSize: 30)
//        let colors: [UIColor] = isCurrentSet ? [Color.ui.cellNo, Settings.shared.accentColor.color] : [.systemGray, .systemGray]
//        config = config.applying(UIImage.SymbolConfiguration(paletteColors: colors))
//        setButton.setImage(UIImage(systemName: "\(indexPath.row + 1).circle", withConfiguration: config), for: .normal)
//
//        // Selected
//        var selectedConfig = UIImage.SymbolConfiguration(pointSize: 30)
//        selectedConfig = selectedConfig.applying(UIImage.SymbolConfiguration(paletteColors: [.white, Settings.shared.accentColor.color]))
//        setButton.setImage(UIImage(systemName: "\(indexPath.row + 1).circle.fill", withConfiguration: selectedConfig), for: .selected)
//
//        if previousWeights.count > 0 {
//            // Use previous weight
//            if indexPath.row < previousWeights.count {
//                let (previousWeight, previousReps) = previousWeights[indexPath.row]
//                previousLabel.text = previousWeight
//                weightTextField.placeholder = previousWeight
//                repsTextField.placeholder = previousReps
//            }
//            else {
//                // Out of bounds, use last weight instead
//                if let (previousWeight, previousReps) = previousWeights.last {
//                    previousLabel.text = "-"
//                    weightTextField.placeholder = previousWeight
//                    repsTextField.placeholder = previousReps
//                }
//            }
//        } else {
//            // No previous weight, use default values
//            previousLabel.text = "-"
//            weightTextField.placeholder = Settings.shared.weightUnit == .lbs ? "135" : "60"
//            repsTextField.placeholder = "5"
//        }
//    }
    
    @objc func doneButtonTapped() {
        endEditing(true)
    }
    
    @objc func previousButtonTapped() {
        delegate?.workoutDetailTableViewCell(self, previousButtonTapped: true)
    }
    
    @objc func nextButtonTapped() {
        delegate?.workoutDetailTableViewCell(self, nextButtonTapped: true)
    }
    
    @objc func increment() {
        if weightTextField.isFirstResponder {
//            var weight: Double
//            if set.weight == "" {
//                weight = Double(weightTextField.placeholder ?? "0") ?? 0.0
//            } else {
//                weight = Double(set.weight) ?? 0.0
//            }
//            
//            weight += Settings.shared.weightIncrement
//            
//            print(String(format: "%g", weight.rounded(toPlaces: 2)))
//            set.weight = String(format: "%g", weight.rounded(toPlaces: 2))
//            weightTextField.text = String(format: "%g", weight.rounded(toPlaces: 2))
        }
        else if repsTextField.isFirstResponder {
//            var reps: Int
//            if set.reps == "" {
//                reps = Int(repsTextField.placeholder ?? "0") ?? 0
//            } else {
//                reps = Int(set.reps ) ?? 0
//            }
//            reps += 1
//            set.reps = String(reps)
//            repsTextField.text = String(reps)
        }
        if Settings.shared.enableHaptic {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    @objc func decrement() {
//        if weightTextField.isFirstResponder {
//            var weight: Double
//            if set.weight == "" {
//                weight = Double(weightTextField.placeholder ?? "0") ?? 0.0
//            } else {
//                weight = Double(set.weight ) ?? 0.0
//            }
//            weight = max(weight - Settings.shared.weightIncrement, 0)
//            print(String(format: "%g", weight.rounded(toPlaces: 2)))
//            set.weight = String(format: "%g", weight.rounded(toPlaces: 2))
//            weightTextField.text = String(format: "%g", weight.rounded(toPlaces: 2))
//        }
//        else if repsTextField.isFirstResponder {
//            var reps: Int
//            if set.reps == "" {
//                reps = Int(repsTextField.placeholder ?? "0") ?? 0
//            } else {
//                reps = Int(set.reps ?? "0") ?? 0
//            }
//            reps = max(reps - 1, 0)
//            set.reps = String(reps)
//            repsTextField.text = String(reps)
//        }
//        if Settings.shared.enableHaptic {
//            let generator = UIImpactFeedbackGenerator(style: .light)
//            generator.impactOccurred()
//        }
    }
}

#Preview {
    WorkoutDetailTableViewCell()
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
