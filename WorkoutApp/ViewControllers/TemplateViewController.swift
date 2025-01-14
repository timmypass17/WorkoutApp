//
//  CreateWorkoutViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/27/24.
//

import UIKit
import CoreData

//protocol CreateWorkoutViewControllerDelegate: AnyObject {
//    func createWorkoutViewController(_ viewController: TemplateViewController, didCreateWorkoutTemplate template: Template)
//}

class TemplateViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var template: Template
    let childContext: NSManagedObjectContext

    init(template: Template, childContext: NSManagedObjectContext) {
        self.template = template
        self.childContext = childContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Section: Int, CaseIterable {
        case title, exercises
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TemplateTitleTableViewCell.self, forCellReuseIdentifier: TemplateTitleTableViewCell.reuseIdentifier)
        tableView.register(TemplateExerciseTableViewCell.self, forCellReuseIdentifier: TemplateExerciseTableViewCell.reuseIdentifier)
        tableView.register(AddTemplateExerciseTableViewCell.self, forCellReuseIdentifier: AddTemplateExerciseTableViewCell.reuseIdentifier)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: didTapCancelButton())
        navigationItem.rightBarButtonItems = [editButtonItem]

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func updateSaveButton() {
        navigationItem.rightBarButtonItems?[0].isEnabled = !template.title.isEmpty
    }
    
    func didTapCancelButton() -> UIAction {
        return UIAction { _ in
            self.dismiss(animated: true)
        }
    }
}

extension TemplateViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .title:
            return 1
        case .exercises:
            let button = 1
            return template.templateExercises.count + button
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: TemplateTitleTableViewCell.reuseIdentifier, for: indexPath) as! TemplateTitleTableViewCell
            cell.delegate = self
            cell.update(title: template.title)
            return cell
        case .exercises:
            let isAddButtonRow = indexPath.row == template.templateExercises.count
            if isAddButtonRow {
                let cell = tableView.dequeueReusableCell(withIdentifier: AddTemplateExerciseTableViewCell.reuseIdentifier, for: indexPath) as! AddTemplateExerciseTableViewCell
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TemplateExerciseTableViewCell.reuseIdentifier, for: indexPath) as! TemplateExerciseTableViewCell
            let templateExercise = template.templateExercises[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.update(templateExercise: templateExercise)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        switch section {
        case .title:
            return "Title"
        case .exercises:
            return "Exercises"
        }
    }
}

extension TemplateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isAddButtonRow = indexPath.row == template.templateExercises.count
        guard let section = Section(rawValue: indexPath.section),
              section == .exercises
        else { return }
        
        if isAddButtonRow {
            tableView.deselectRow(at: indexPath, animated: true)
            let exercisesTableViewController = ExercisesTableViewController()
            exercisesTableViewController.delegate = self
            let vc = UINavigationController(rootViewController: exercisesTableViewController)
            self.present(vc, animated: true)
        } else {
            let exercise = template.templateExercises[indexPath.row]
            let exerciseDetailViewController = EditExerciseDetailViewController(exercise: exercise.name, sets: Int(exercise.sets), reps: Int(exercise.reps))
            exerciseDetailViewController.delegate = self
            let vc = UINavigationController(rootViewController: exerciseDetailViewController)
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium()]
            }
            present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let isAddButtonRow = indexPath.row == template.templateExercises.count
        guard let section = Section(rawValue: indexPath.section) else { return false }
        
        return section == .exercises && !isAddButtonRow
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let exerciseToRemove = template.templateExercises[indexPath.row]
            template.removeFromTemplateExercises_(exerciseToRemove) // note: Does not delete exercise, still persisted
            childContext.delete(exerciseToRemove)                   // Exercise is marked for deletion
            
            do {
                try childContext.save() // Exercise is now deleted
            } catch {
                print("Error saving reordered items: \(error)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.section != 0 else { return }
        
        // Update the data source
        let exerciseToMove = template.templateExercises[sourceIndexPath.row]
        template.removeFromTemplateExercises_(exerciseToMove)
        template.insertIntoTemplateExercises_(exerciseToMove, at: destinationIndexPath.row)
                
        // Update the orderIndex for all items
        for (index, exercise) in template.templateExercises.enumerated() {
            exercise.index = Int16(index)
        }
        
        // Save the context
        do {
            try childContext.save()
        } catch {
            print("Error saving reordered items: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // Restricts cell's reorder destination (i.e. repositioning exercise under "Add Exercise" button)
        let isAddExerciseButtonRow = template.templateExercises.count
        guard let destinationSection = Section(rawValue: proposedDestinationIndexPath.section),
              destinationSection == .exercises,
              proposedDestinationIndexPath.row != isAddExerciseButtonRow
        else { return sourceIndexPath }
        
        return proposedDestinationIndexPath
    }
}


extension TemplateViewController: AddExerciseDetailViewControllerDelegate {
    func addExerciseDetailViewControllerDelegate(_ viewController: AddExerciseDetailViewController, didAddExercise exercise: String, sets: Int, reps: Int) {
        print("Added \(exercise) \(sets) x \(reps)")
        let sampleExercise = TemplateExercise(context: childContext)
        sampleExercise.name = exercise
        sampleExercise.sets = Int16(sets)
        sampleExercise.reps = Int16(reps)
        sampleExercise.template = template
        template.addToTemplateExercises_(sampleExercise)
        
        tableView.insertRows(at: [IndexPath(row: template.templateExercises.count - 1, section: Section.exercises.rawValue)], with: .automatic)
    }
    
    func addExerciseDetailViewControllerDelegate(_ viewController: AddExerciseDetailViewController, didDismiss: Bool) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedIndexPath, animated: true)
    }

}

extension TemplateViewController: EditExerciseDetailViewControllerDelegate {
    func editExerciseDetailViewControllerDelegate(_ viewController: EditExerciseDetailViewController, didUpdateExercise exercise: String, sets: Int, reps: Int) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        let exercise = template.templateExercises[selectedIndexPath.row]
        exercise.sets = Int16(sets)
        exercise.reps = Int16(reps)
        
        tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        print("Updated \(exercise) \(sets) x \(reps)")
    }
    
    func editExerciseDetailViewControllerDelegate(_ viewController: EditExerciseDetailViewController, didDismiss: Bool) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
}

extension TemplateViewController: TemplateTitleTableViewCellDelegate {
    func templateTitleTableViewCell(_ cell: TemplateTitleTableViewCell, titleTextFieldDidChange title: String) {
        template.title = title
        updateSaveButton()
    }
}
