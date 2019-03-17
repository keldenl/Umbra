//
//  ViewController.swift
//  iQuiz
//
//  Created by Kelden Lin on 2/11/19.
//  Copyright © 2019 Kelden Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    var editingTaskId = (-1,-1)
    var LOCK_EDITING = false
    
    @IBOutlet weak var mainNavBar: UINavigationBar!
    @IBOutlet weak var mainNavText: UINavigationItem!
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
        if newTaskView.alpha == 0 { newTaskVisible(visible: true) }

        // Send haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    @IBAction func newTaskCancel(_ sender: Any) {
        newTaskVisible(visible: false)
        newTaskPicker.date = Date()
        editingTaskId = (-1,-1)
    }
    
    func newTaskVisible(visible : Bool) {
        if (!visible) {
            view.endEditing(true) // Remove focus
            // Reset options
            self.newTaskTextfield.text = ""
            newTaskAddButton.setTitle("Add task to list", for: [])
            newTaskPicker.date = Date()
        }
        
        let multiplier : CGFloat = visible ? 1 : -1
        
        navBarConstraint.constant -= 40 * multiplier
        newTaskViewConstraint.constant -= 40 * multiplier
        newTaskTextfieldConstraint.constant -= 40 * multiplier
        newTaskTextfieldTrailingConstraint.constant += 55 * multiplier
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut,
                       animations: {
                        self.newTaskView.alpha = visible ? 1 : 0
                        self.mainNavBar.alpha = visible ? 0 : 1
                        self.view.layoutIfNeeded()
        })
    }
    
    // Custom functions
    //
    func updateTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        mainNavText.title = dateFormatter.string(from: Date())
    }
    
    // Data Manipulation
    func convertToOneArray(_ arr : [[Task]]) -> [Task] {
        var returnArray : [Task] = []
        for e in arr {
            returnArray.append(contentsOf: e)
        }
        return returnArray
    }
    
    func hideDoneTasks(_ tasks : [[Task]]) -> [[Task]] {
        var returnTasks : [[Task]] = [[],[],[],[]]
        for i in 0..<tasks.count {
            for t in tasks[i] {
                if (!t.done) { returnTasks[i].append(t) }
            }
        }

        return returnTasks
    }
    
    func resortTasks(_ tasks : [Task]) -> [[Task]]  {
        var returnTasks = [[Task]]()
        var overdue = [Task]()
        var today = [Task]()
        var tomorrow = [Task]()
        var other = [Task]()
        
        for t in tasks {
            let dueDiff = Calendar.current.dateComponents([.day, .hour], from: Date(), to: t.dueDate)
            if dueDiff.day ?? 0 < 0 { overdue.append(t) }
            else {
                switch t.dueDate {
                case let d where Calendar.current.isDateInToday(d!): today.append(t)
                case let d where Calendar.current.isDateInTomorrow(d!): tomorrow.append(t)
                default: other.append(t)
                }
            }
        }
        
        returnTasks = [overdue, today, tomorrow, other]
        for i in 0..<returnTasks.count {
            returnTasks[i] = returnTasks[i].sorted(by: { $0.dueDate < $1.dueDate })
        }
        
        return returnTasks
    }
    
    func reloadData() {
        tasks = hideDoneTasks(resortTasks(fullTaskList))
        taskRepo.saveTasks(tasks)
        fullTaskList = convertToOneArray(tasks)
        dataSource = TaskDataSource(tasks)
        mainTableView.dataSource = dataSource
        mainTableView.reloadData()
    }
    
    
    
    // Main interactions
    @IBAction func createTask(_ sender: Any) {
        if newTaskTextfield.text != nil && newTaskTextfield.text?.trimmingCharacters(in: .whitespaces) != "" {
            if editingTaskId != (-1, -1) {
                self.tasks[editingTaskId.0][editingTaskId.1].name = newTaskTextfield.text!
                self.tasks[editingTaskId.0][editingTaskId.1].dueDate = newTaskPicker.date
                editingTaskId = (-1,-1)
            }
            else {
                self.fullTaskList.append(Task(name:newTaskTextfield.text!, dueDate: newTaskPicker.date))
                print("added new task")
            }
            self.reloadData()
            newTaskVisible(visible: false)
        }
        // User left the space blank
        else {
            let alert = UIAlertController(title: "Empty Task Name", message: "Please enter a task name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in return }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Takes in "fullTaskList" index and returns "task" indexes
    func getSectionRowIndex(_ fullIndex : Int) -> [Int] {
        var taskSection : Int = 0
        var rowIndex : Int = 0
        
        var currIndex : Int = 0
        for i in 0..<self.tasks.count {
            for k in 0..<self.tasks[i].count {
                if k + currIndex == fullIndex {
                    taskSection = i
                    rowIndex = k
                }
            }
            currIndex += self.tasks[i].count
        }
        
        return [taskSection, rowIndex]
    }
    
    
    @IBAction func donePressed (_ sender : UIButton) {
        if !self.LOCK_EDITING {
            fullTaskList[sender.tag].done = !fullTaskList[sender.tag].done
            mainTableView.reloadData()
            self.LOCK_EDITING = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let removeIndex = self.getSectionRowIndex(sender.tag)
                let senderTag = self.tasks[removeIndex[0]].count > sender.tag ? sender.tag : sender.tag - 1 // Fixes edgecase completing last 2 tasks
                if self.fullTaskList[senderTag].done {
                    self.fullTaskList.remove(at: senderTag)
                    self.tasks[removeIndex[0]].remove(at: removeIndex[1])
                    self.dataSource?.data[removeIndex[0]].remove(at: removeIndex[1])
                    self.taskRepo.saveTasks(self.tasks)
                    
                    self.mainTableView.deleteRows(at: [IndexPath(row: removeIndex[1], section: removeIndex[0])], with: .fade)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.mainTableView.reloadData()
                        self.LOCK_EDITING = false
                    }
                } else {
                    self.LOCK_EDITING = false
                }
            }
        }
        
    }
    
    
    // Data
    var dataSource : TaskDataSource? = nil
    var taskRepo : TaskRepository = (UIApplication.shared.delegate as! AppDelegate).taskRepository
    var tasks : [[Task]] = [[]]
    var fullTaskList : [Task] = []
    let sectionHeaders : [String] = ["Overdue", "Today", "Tomorrow", "Upcoming"]

    
    // TableView Editing & Header
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !LOCK_EDITING { // No editing when done pressed
            editingTaskId = (indexPath.section, indexPath.row)
            newTaskTextfield.text = tasks[editingTaskId.0][editingTaskId.1].name
            newTaskPicker.date = tasks[editingTaskId.0][editingTaskId.1].dueDate
            newTaskAddButton.setTitle("Apply changes", for: [])
            newTaskTextfield.becomeFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.black
        let headerLabel = UILabel(frame: CGRect(x: 13, y: 8, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.bold)
        headerLabel.textColor = UIColor.white
        headerLabel.text = sectionHeaders[section]
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // Update the date
//    func calendarDayDidChange(notification : NSNotification) { updateTitle() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateTitle()
        newTaskTextfield.attributedPlaceholder = NSAttributedString(string: "New task",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        tasks = taskRepo.getTasks()
        fullTaskList = convertToOneArray(tasks)
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
