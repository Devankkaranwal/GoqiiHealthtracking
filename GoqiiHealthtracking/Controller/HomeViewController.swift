//
//  HomeViewController.swift
//  waterWave_progess
//
//  Created by Devank on 17/04/24.
//

import UIKit
import UserNotifications

let screenWidth = UIScreen.main.bounds.size.width

class HomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var percentlbls: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var hydration: HydrationModel
    var waterWaveView = WaterWaveView()
    
    init(hydration: HydrationModel) {
            self.hydration = hydration
            super.init(nibName: nil, bundle: nil)
        }

    
    required init?(coder: NSCoder) {
        self.hydration = HydrationModel(date: Date(), goal: 3700, goalIndex: 0, totalIntake: 0, progress: 0.0, intake: [])
        super.init(coder: coder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DrinkCell")

        view.addSubview(waterWaveView)
        
        let progress = CGFloat(self.hydration.totalIntake) / CGFloat(self.hydration.goal)
        let firstColor = UIColor.red
        let secondColor = UIColor.green

        self.waterWaveView.setupProgress(progress, firstColor: firstColor, secondColor: secondColor)
        self.waterWaveView.percentLbl.textColor = firstColor
        
        self.setGoalItems(goal: Float(self.hydration.goal), currentValue: Float(self.hydration.totalIntake))
     
        // Set today's date in lblDate
            let today = Date()
            let todayDateString = DateHelper.getDateString(day: today)
            lblDate.text = "Today: \(todayDateString)"

           NSLayoutConstraint.activate([
               waterWaveView.widthAnchor.constraint(equalToConstant: screenWidth*0.5),
               waterWaveView.heightAnchor.constraint(equalToConstant: screenWidth*0.5),
               waterWaveView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 130),
               waterWaveView.centerXAnchor.constraint(greaterThanOrEqualTo: view.centerXAnchor, constant: -10)
           ])
        
        // Request notification authorization
              UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                  if granted {
                      self.scheduleNotification()
                  } else {
                     print("Request notification authorization")
                  }
              }
    }
    
    
    func scheduleNotification() {
            let content = UNMutableNotificationContent()
            content.title = "Stay Hydrated!"
            content.body = "Don't forget to drink water and meet your daily hydration goals."
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 8
            dateComponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: "hydrationReminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully")
                }
            }
        }
    
    
    override func viewWillLayoutSubviews() {
        self.setGoalItems(goal: Float(self.hydration.goal), currentValue: Float(self.hydration.totalIntake))
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hydration.intake.count
    }


    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkCell", for: indexPath)
        let drink = hydration.intake[indexPath.row]
        cell.textLabel?.text = "\(drink.amount) mL - \(Constants.drinks[drink.drinkID])"
        cell.detailTextLabel?.text = DateHelper.getTimeString(time: drink.date)
        cell.imageView?.image = UIImage(named: "Water")
        
        return cell
    }

    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedAmount = hydration.intake[indexPath.row].amount
            hydration.removeIntake(offset: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.hydration.totalIntake -= deletedAmount
            self.setGoalItems(goal: Float(self.hydration.goal), currentValue: Float(self.hydration.totalIntake))

        }
    }
    


    
    func setGoalItems(goal: Float, currentValue: Float) {
        let newGoal: Float = 3700  // Set the new goal here

        let progress = CGFloat(currentValue) / CGFloat(newGoal)
        let percentString = String(format: "%.0f", progress * 100) + "%"
        
        let firstColor = UIColor(red: 1.0 - progress, green: progress, blue: 0.0, alpha: 1.0)
        let secondColor = UIColor(red: 1.0 - progress, green: progress, blue: 0.0, alpha: 0.5)
        
        
        self.hydration.goal = Int(newGoal)
        self.waterWaveView.setupProgress(progress, firstColor: firstColor, secondColor: secondColor)
        self.waterWaveView.percentLbl.textColor = firstColor
        
        percentlbls.text = percentString
    }


    
    
    
    @IBAction func addIntakeButtonTapped(_ sender: Any) {
      
        let alert = UIAlertController(title: "Add Intake", message: "Enter the amount of water consumed (mL):", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Amount"
                textField.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
                if let amountText = alert.textFields?.first?.text, let amount = Int(amountText) {
                    let waterData = WaterData(amount: amount, drinkID: 0, date: Date())
                    self.hydration.intake.append(waterData)
                    self.hydration.totalIntake += amount
                    self.tableView.reloadData()

                    let progress = CGFloat(self.hydration.totalIntake) / CGFloat(self.hydration.goal)
                    let percentString = String(format: "%.0f", progress * 100) + "%"
                    let firstColor = UIColor.red // Set your desired colors here
                    let secondColor = UIColor.green
                    self.percentlbls.text = percentString

                    self.waterWaveView.setupProgress(progress, firstColor: firstColor, secondColor: secondColor)
                    self.waterWaveView.percentLbl.textColor = firstColor

                    self.waterWaveView.updateProgressLabel(currentValue: Float(self.hydration.totalIntake), goal: Float(self.hydration.goal))
                }
            }))
            present(alert, animated: true, completion: nil)
        
        
    }
    
    
}
