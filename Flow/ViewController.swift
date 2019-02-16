//
//  ViewController.swift
//  iQuiz
//
//  Created by Kelden Lin on 2/11/19.
//  Copyright © 2019 Kelden Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    var editingTaskId = -1
    
    @IBOutlet weak var mainNavBar: UINavigationBar!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var newTaskPicker: UIDatePicker!
    @IBOutlet weak var newTaskTextfield: UITextField!
    
    @IBOutlet weak var navBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskView: UIView!
    @IBOutlet weak var newTaskViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskTextfieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskTextfieldTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskAddButton: UIButton!
    
    // New Task Functions
    @IBAction func newTaskTriggered(_ sender: Any) {
        newTaskVisible(visible: true)
    }
    
    @IBAction func newTaskCancel(_ sender: Any) {
        newTaskVisible(visible: false)
        newTaskPicker.date = Date()
    }
    
    func newTaskVisible(visible : Bool) {
        if (!visible) {
            self.newTaskTextfield.text = ""
            view.endEditing(true)
        }
        let multiplier : CGFloat = visible ? 1 : -1
        
        navBarConstraint.constant -= 50 * multiplier
        newTaskViewConstraint.constant -= 50 * multiplier
        newTaskTextfieldConstraint.constant -= 50 * multiplier
        newTaskTextfieldTrailingConstraint.constant += 50 * multiplier
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut,
                       animations: {
                        self.newTaskView.alpha = visible ? 1 : 0
                        self.mainNavBar.alpha = visible ? 0 : 1
                        self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func createTask(_ sender: Any) {
        if (editingTaskId != -1) {
            self.tasks[editingTaskId].name = newTaskTextfield.text!
            self.tasks[editingTaskId].dueDate = newTaskPicker.date
            editingTaskId = -1
            newTaskPicker.date = Date()
            newTaskAddButton.setTitle("Add task to list", for: [])
        }
        else {
            self.tasks.append(Task(name:newTaskTextfield.text!, dueDate: newTaskPicker.date))
        }
        self.reloadData()
        newTaskVisible(visible: false)
    }
    
    @IBAction func donePressed (_ sender : UIButton) {
        tasks[sender.tag].done = !tasks[sender.tag].done
        mainTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { self.reloadData() }
    }
    
    var dataSource : TaskDataSource? = nil
    var taskRepo : TaskRepository = (UIApplication.shared.delegate as! AppDelegate).taskRepository
    var tasks : [Task] = []
    var doneTasks : [Task] = []
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row at \(indexPath.row)")
        editingTaskId = indexPath.row
        newTaskTextfield.text = tasks[editingTaskId].name
        newTaskPicker.date = tasks[editingTaskId].dueDate
        newTaskAddButton.setTitle("Apply changes", for: [])
        newTaskTextfield.becomeFirstResponder()
    }
    
    func hideDoneTasks(_ tasks : [Task]) -> ([Task], [Task]) {
        var returnTasks = [Task]()
        var doneTasks = [Task]()
        for t in tasks {
            if (!t.done) { returnTasks.append(t) }
            else { doneTasks.append(t) }
        }
        
        return (returnTasks, doneTasks)
    }
    
    func reloadData() {
        var newDoneTasks : [Task] = []
        (tasks, newDoneTasks) = hideDoneTasks(tasks)
        doneTasks.append(contentsOf: newDoneTasks)
        dataSource = TaskDataSource(tasks)
        mainTableView.dataSource = dataSource
        mainTableView.reloadData()
        print(doneTasks.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tasks = taskRepo.getTasks()
        dataSource = TaskDataSource(tasks)
        mainTableView.dataSource = dataSource
        mainTableView.delegate = self
        
        newTaskPicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    // Status bar update
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

