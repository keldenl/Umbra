//
//  Task.swift
//  iQuiz
//
//  Created by Kelden Lin on 2/11/19.
//  Copyright © 2019 Kelden Lin. All rights reserved.
//

import Foundation
import UIKit

class Task {
    init(name: String, dueDate: Date, done: Bool = false) {
        self.name = name
        self.dueDate = dueDate
        self.done = done
    }
    
    var name = ""
    var dueDate = Date()
    var done = false
    
//    var fullName : String {
//        get { return firstName + " " + lastName }
//    }
}

protocol TaskRepository {
    func getTasks() -> [[Task]] // size: 4
//    func newTask(_ task : Task) -> Bool
//    func findPersonByLastName(_ lastName : String) -> [Person]
}

class SimpleTaskRepository : TaskRepository {
    var taskData = [Task]()
//    var doneTaskData = [Task]()
    private static var _repo : TaskRepository? = nil
    static var theInstance : TaskRepository {
        get {
            if _repo == nil { _repo = SimpleTaskRepository() }
            return _repo!
        }
    }
    
    let localTestingData : [[Task]] = [[
        Task(name: "Finish Math HW", dueDate: Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "PST"), year: 2019, month: 2, day: 11, hour: 19, minute: 0, second: 0))!, done: false),
        Task(name: "Finish Science HW", dueDate: Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "PST"), year: 2019, month: 2, day: 11, hour: 23, minute: 0, second: 0))!, done: false),
        Task(name: "Finish English HW", dueDate: Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "PST"), year: 2019, month: 2, day: 11, hour: 20, minute: 0, second: 0))!, done: false)
    ], [Task](), [Task](), [Task]()]
    
    func getTasks() -> [[Task]] {
//        taskData = taskData.count == 0 ? localTestingData : taskData
        return localTestingData
    }
    
    
//    func newTask(_ task: Task) -> Bool {
//        print("Added \(task.name)")
//        taskData.append(task)
//        return true
//    }
//    func savePersons(data: [Task]) -> Bool {
//        return true
//    }
//    func findPersonByLastName(_ lastName: String) -> [Task] {
//        return []
//    }
}
