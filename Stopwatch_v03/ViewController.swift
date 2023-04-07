//
//  ViewController.swift
//  Stopwatch_v03
//
//  Created by Max Franz Immelmann on 4/7/23.
//

import UIKit

class ViewController: UIViewController {
    
    var digitalStartTime: TimeInterval?
    var timer: Timer?
    
    let handLayer = CAShapeLayer()
    
    let digitalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 64,
                                                      weight: .regular)
        label.textAlignment = .center
        label.text = "00:00.00"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMinuteMarks()
        addHandLayer(handLayer: handLayer)
        addCenterCircle()
        
        addDigitalView(digitalTimeLabel: digitalTimeLabel)
        addStartButton()
    }
    
    func addStartButton() {
        let startButton = UIButton(type: .system)
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .orange
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        startButton.setTitleColor(UIColor.white, for: .normal)
        startButton.layer.cornerRadius = 25
        startButton.addTarget(self,
                              action: #selector(startStopwatch),
                              for: .touchUpInside)
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -30),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func startStopwatch() {
        if timer == nil {
            // Start the timer
            digitalStartTime = Date().timeIntervalSinceReferenceDate
            timer = Timer.scheduledTimer(timeInterval: 0.01,
                                         target: self,
                                         selector: #selector(updateDigitalTimeLabel),
                                         userInfo: nil,
                                         repeats: true)
            
            // Change button title to "Stop"
            if let startButton = view.subviews.first(where: { $0 is UIButton }) as? UIButton {
                startButton.setTitle("Stop", for: .normal)
            }
        } else {
            // Stop the timer
            timer?.invalidate()
            timer = nil
            
            // Change button title to "Start"
            if let startButton = view.subviews.first(where: { $0 is UIButton }) as? UIButton {
                startButton.setTitle("Start", for: .normal)
            }
        }
    }
    
    @objc func updateDigitalTimeLabel() {
        guard let startTime = digitalStartTime else { return }
        
        // Calculate elapsed time
        let currentTime = Date().timeIntervalSinceReferenceDate
        let elapsedTime = currentTime - startTime
        
        // Format elapsed time as minutes, seconds, and hundredths of a second
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime) % 60
        let hundredths = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        
        // Update time label text
        digitalTimeLabel.text = String(format: "%02d:%02d.%02d",
                                       minutes,
                                       seconds,
                                       hundredths)
        
        // Update the hand position
        let fullSeconds = Float(seconds) + Float(hundredths) / 100
        let angle = 2 * .pi * fullSeconds / 60 - .pi / 2
        
        let circleCenter = CGPoint(x: view.center.x, y: view.center.y)
        let circleRadius = view.bounds.width / 2 * 0.65
        let handPath = UIBezierPath()
        handPath.move(to: circleCenter)
        handPath.addLine(to: CGPoint(x: circleCenter.x + circleRadius * CGFloat(cos(angle)),
                                     y: circleCenter.y + circleRadius * CGFloat(sin(angle))))
        handLayer.path = handPath.cgPath
    }
}

extension UIViewController {
    
    func addMinuteMarks() {
  
        let minSize = min(view.frame.height, view.frame.width) * 0.8
        
        let markSize = CGSize(width: 8, height: 2)
        let markRadius = minSize / 2 - markSize.width

        for i in 0..<60 {
            let mark = UIView(frame: CGRect(origin: .zero, size: markSize))
            let angle = CGFloat(i) / 60.0 * 2.0 * CGFloat.pi
            mark.frame.size.width = i % 5 == 0 ? 16 : 8
            let x = cos(angle) * markRadius + view.frame.width / 2
            let y = sin(angle) * markRadius + view.frame.height / 2
            mark.center = CGPoint(x: x, y: y)
            mark.backgroundColor = UIColor.black
            mark.transform = CGAffineTransform(rotationAngle: angle)
            view.addSubview(mark)
        }
    }
     
    
    func addDigitalView(digitalTimeLabel: UIView) {
        view.addSubview(digitalTimeLabel)
        digitalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            digitalTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            digitalTimeLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
        ])
    }
    
    func addHandLayer(handLayer: CAShapeLayer) {
        // Set up the hand layer
        let handPath = UIBezierPath()
        handPath.move(to: view.center)
        let circleRadius = view.bounds.width / 2 * 0.65
        handPath.addLine(to: CGPoint(x: view.center.x,
                                     y: view.center.y - circleRadius))
        handLayer.path = handPath.cgPath
        handLayer.strokeColor = UIColor.orange.cgColor
        handLayer.lineWidth = 3
        handLayer.lineCap = .round
        view.layer.addSublayer(handLayer)
    }
    
    func addCenterCircle() {
        let circleRadius = view.frame.width / 30
        let circleCenter = CGPoint(x: view.frame.width / 2,
                                   y: view.frame.height / 2)

        let orangeCircle = UIView(frame: CGRect(origin: .zero,
                                                size: CGSize(
                                                    width: circleRadius * 2 - 6,
                                                    height: circleRadius * 2 - 6
                                                )))
        orangeCircle.backgroundColor = UIColor.orange
        orangeCircle.layer.cornerRadius = (circleRadius * 2 - 6.0) / 2.0
        orangeCircle.center = circleCenter
        view.addSubview(orangeCircle)
    }
}
