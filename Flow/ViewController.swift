//
//  ViewController.swift
//  iQuiz
//
//  Created by Kelden Lin on 2/11/19.
//  Copyright © 2019 Kelden Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var mainNavBar: UINavigationBar!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var newTaskPicker: UIDatePicker!
    @IBOutlet weak var newTaskTextfield: UITextField!
    
    @IBOutlet weak var navBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskView: UIView!
    @IBOutlet weak var newTaskViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskTextfieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskTextfieldTrailingConstraint: NSLayoutConstraint!
    
    @IBAction func newTaskTriggered(_ sender: Any) {
        newTaskVisible(visible: true)
    }
    
    @IBAction func newTaskCancel(_ sender: Any) {
        newTaskVisible(visible: false)
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
        self.tasks.append(Task(name:newTaskTextfield.text!, dueDate: Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "PST"), year: 2019, month: 2, day: 11, hour: 19, minute: 0, second: 0))!))
        self.reloadData()
        newTaskVisible(visible: false)
    }
//    @IBAction func newTask(_ sender: Any) {
////         Show placeholder alert for settings
//        let alert = UIAlertController(title: "New Task", message: "", preferredStyle: .alert)
//        // Add Text Field
//        alert.addTextField { (textField) in textField.placeholder = "Task name" }
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
//            self.tasks.append(Task(name: alert!.textFields![0].text!, dueDate: Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "PST"), year: 2019, month: 2, day: 11, hour: 19, minute: 0, second: 0))!))
//            self.reloadData()
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in return }))
//        self.present(alert, animated: true, completion: nil)
//    }
    
    @IBAction func donePressed (_ sender : UIButton) {
        tasks[sender.tag].done = !tasks[sender.tag].done
        mainTableView.reloadData()
        print(sender.tag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            // Code you want to be delayed
            self.reloadData()
        }
    }
    
    var dataSource : TaskDataSource? = nil
    var taskRepo : TaskRepository = (UIApplication.shared.delegate as! AppDelegate).taskRepository
    var tasks : [Task] = []
    var doneTasks : [Task] = []
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row at \(indexPath.row)")
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
        // Hiding Keyboard
//        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
//        tap.cancelsTouchesInView = false
//        self.view.addGestureRecognizer(tap)
        
        tasks = taskRepo.getTasks()
        dataSource = TaskDataSource(tasks)
        mainTableView.dataSource = dataSource
        mainTableView.delegate = self
        
        newTaskPicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

