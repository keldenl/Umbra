//
//  QuizDataSource.swift
//  iQuiz
//
//  Created by Kelden Lin on 2/11/19.
//  Copyright © 2019 Kelden Lin. All rights reserved.
//

import Foundation
import UIKit

class TaskDataSource : NSObject, UITableViewDataSource
{
    var data : [Task] = []
    init(_ elements : [Task]) {
        data = elements
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        assert(section == 0)
//        return "SWIPE DOWN TO ADD ITEM"
//    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! MainCell
        let currData = data[indexPath.row]

        cell.taskName.text = currData.name
        
//        Date Formatter Information
//
//        Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
//        09/12/2018                        --> MM/dd/yyyy
//        09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
//        Sep 12, 2:11 PM                   --> MMM d, h:mm a
//        September 2018                    --> MMMM yyyy
//        Sep 12, 2018                      --> MMM d, yyyy
//        Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
//        2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
//        12.09.18                          --> dd.MM.yy
//        10:41:02.112                      --> HH:mm:ss.SSS
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()

        dateFormatter.dateFormat = "E, MMM d"
        timeFormatter.dateFormat = "h:mm a"
        cell.taskDueDate.text = "\(dateFormatter.string(from: currData.dueDate)) at \(timeFormatter.string(from: currData.dueDate))"
        
        let doneImg = currData.done ? UIImage(named: "done") : UIImage(named: "undone")
        cell.taskDone.setImage(doneImg, for: [])
        cell.taskDone.tag = indexPath.row
        
        return cell
    }
}
