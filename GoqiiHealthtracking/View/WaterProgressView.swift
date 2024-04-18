//
//  WaterProgressView.swift
//  GoqiiHealthtracking
//
//  Created by Devank on 17/04/24.
//




import UIKit
class WaterWaveView: UIView{
    
   

    private let firstlayer = CAShapeLayer()
    private let secondLayer = CAShapeLayer()

     var percentLbl = UILabel()

    private var firstColor: UIColor = .clear
    private var secondColor: UIColor = .clear

    private let twon: CGFloat = .pi*2
    private var offset: CGFloat = 0.0

     let width = screenWidth*0.5


    var showSingleWave = false
    private var start = false

    var progress: CGFloat = 0.0
    var waveHeight: CGFloat = 0.0




    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }


    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}



 //MARK: Setup Views

extension WaterWaveView{
    private func setupViews() {

        bounds = CGRect(x: 0.0, y: 0.0, width: min(width,width), height: min(width,width))

        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = width/2
        layer.masksToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor


        waveHeight = 8.0

        firstColor = .systemOrange
        secondColor = .systemPink

        createFirstLayer()

        if !showSingleWave {
            createSecondLayer()
        }
        createPercentLbl()
    }

    // MARK: Create First Layer

    private func createFirstLayer() {

        firstlayer.frame = bounds
        firstlayer.anchorPoint = .zero
        firstlayer.fillColor = firstColor.cgColor
        layer.addSublayer(firstlayer)
    }

    private func createSecondLayer() {

        secondLayer.frame = bounds
        secondLayer.anchorPoint = .zero
        secondLayer.fillColor = secondColor.cgColor
        layer.addSublayer(secondLayer)

    }

    private func createPercentLbl(){
        percentLbl.font = UIFont.boldSystemFont(ofSize: 12)
        percentLbl.textAlignment = .center
        percentLbl.text = ""
        //percentLbl.text = "Used"
        percentLbl.textColor = .white
        addSubview(percentLbl)
        percentLbl.translatesAutoresizingMaskIntoConstraints = false
        percentLbl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        percentLbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func percentAnim(){
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.duration = 1.5
        anim.fromValue = 0.0
        anim.toValue = 1.5
        anim.repeatCount = .infinity
        anim.isRemovedOnCompletion = false

        percentLbl.layer.add(anim, forKey: nil)

    }


    func updateProgressLabel(currentValue: Float, goal: Float) {
        let percentString = String(format: "%.0f", (currentValue / goal) * 100) + "%"
        percentLbl.text = "\(currentValue) mL / \(goal) mL (\(percentString))"
    }


    
//    func setupProgress(_ progress: CGFloat, firstColor: UIColor, secondColor: UIColor) {
//        guard progress.isFinite && !progress.isNaN else {
//            print("Invalid progress value: \(progress)")
//            return
//        }
//
//        self.firstColor = firstColor
//        self.secondColor = secondColor
//        self.percentLbl.text = "\(Int(progress * 100))%"
//        print("Updated percentLbl.text: \(self.percentLbl.text ?? "")") // Add this line
//        self.setNeedsDisplay()
//
//        // Update the filling color of the WaterWaveView based on the progress
//        let color = UIColor(red: progress, green: 1 - progress, blue: 0, alpha: 1)
//        self.firstlayer.fillColor = color.cgColor
//    }

    

    func setupProgress(_ progress: CGFloat, firstColor: UIColor, secondColor: UIColor) {
        guard progress.isFinite && !progress.isNaN else {
            print("Invalid progress value: \(progress)")
            return
        }

        self.firstColor = firstColor
        self.secondColor = secondColor
        self.percentLbl.text = "\(Int(progress * 100))%"
        print("Updated percentLbl.text: \(self.percentLbl.text ?? "")") // Add this line
        self.progress = progress // Add this line to update the progress property
        self.setNeedsDisplay()
    }

    


    

     func startAnim() {
        start = true
        waterWaveAnim()
    }

    private func waterWaveAnim(){
        let w = bounds.size.width
        let h = bounds.size.height

        let bezier = UIBezierPath()
        let path = CGMutablePath()

        let startoffsetY = waveHeight * CGFloat(sinf(Float(offset*twon/w)))
        var origiOffsetY: CGFloat = 0.0

        path.move(to: CGPoint(x: 0.0, y: startoffsetY),transform: .identity)
        bezier.move(to: CGPoint(x: 0.0, y: startoffsetY))

        for i in stride(from: 0.0, to: w*1000, by: 1){

            origiOffsetY = waveHeight * CGFloat(sinf(Float(twon / w*i + offset * twon/w)))
            bezier.addLine(to: CGPoint(x: i, y: origiOffsetY))

        }

        bezier.addLine(to: CGPoint(x: w*1000, y: origiOffsetY))
        bezier.addLine(to: CGPoint(x: w*1000, y: h))
        bezier.addLine(to: CGPoint(x: 0.0, y: h))
        bezier.addLine(to: CGPoint(x: 0.0, y: startoffsetY))
        bezier.close()

        let anim = CABasicAnimation(keyPath: "transform.translation.x")
        anim.duration = 2.0
        anim.fromValue = -w * 0.5
        anim.toValue = -w - w*0.5
        anim.repeatCount = .infinity
        anim.isRemovedOnCompletion = false


        firstlayer.fillColor = firstColor.cgColor
        firstlayer.path = bezier.cgPath
        firstlayer.add(anim, forKey: nil)


        if !showSingleWave{

            let bezier = UIBezierPath()

            let startoffsetY = waveHeight * CGFloat(sinf(Float(offset*twon/w)))
            var origiOffsetY: CGFloat = 0.0

            bezier.move(to: CGPoint(x: 0.0, y: startoffsetY))

            for i in stride(from: 0.0, to: w*1000, by: 1){
                origiOffsetY = waveHeight*CGFloat(cosf(Float(twon/w*i + offset*twon/w)))
                bezier.addLine(to: CGPoint(x: i, y: origiOffsetY))

            }
            bezier.addLine(to: CGPoint(x: w*1000, y: origiOffsetY))
            bezier.addLine(to: CGPoint(x: w*1000, y: h))
            bezier.addLine(to: CGPoint(x: 0.0, y: h))
            bezier.addLine(to: CGPoint(x: 0.0, y: startoffsetY))
            bezier.close()


            secondLayer.fillColor = secondColor.cgColor
            secondLayer.path = bezier.cgPath
            secondLayer.add(anim, forKey: nil)
        }
    }
    

    
    
    private func updateWave() {
        let progressHeight = bounds.height * progress

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: progressHeight))
        for x in stride(from: 0, through: bounds.width, by: 1) {
            let y = sin((CGFloat(x) / bounds.width + offset) * CGFloat.pi * 2) * waveHeight + progressHeight
            bezierPath.addLine(to: CGPoint(x: x, y: y))
        }
        bezierPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        bezierPath.addLine(to: CGPoint(x: 0, y: bounds.height))
        bezierPath.close()

        firstlayer.fillColor = firstColor.cgColor
        firstlayer.path = bezierPath.cgPath

        if !showSingleWave {
            let secondBezierPath = UIBezierPath()
            secondBezierPath.move(to: CGPoint(x: 0, y: progressHeight))
            for x in stride(from: 0, through: bounds.width, by: 1) {
                let y = cos((CGFloat(x) / bounds.width + offset) * CGFloat.pi * 2) * waveHeight + progressHeight
                secondBezierPath.addLine(to: CGPoint(x: x, y: y))
            }
            secondBezierPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
            secondBezierPath.addLine(to: CGPoint(x: 0, y: bounds.height))
            secondBezierPath.close()

            secondLayer.fillColor = secondColor.cgColor
            secondLayer.path = secondBezierPath.cgPath
        }
    }

    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)

        let width = rect.size.width
        let height = rect.size.height


        guard let percentString = percentLbl.text?.components(separatedBy: " ").last,
              let percentage = Float(percentString.dropLast()) else {
            return
        }

        let progressHeight = height * CGFloat(percentage) / 100.0

        let startY = height - progressHeight
        let wavePath = UIBezierPath()

        wavePath.move(to: CGPoint(x: 0, y: startY))

        for x in stride(from: 0, through: width, by: 1) {
            let y = sin((CGFloat(x) / width) * CGFloat.pi * 2) * (height * 0.03) + startY
            wavePath.addLine(to: CGPoint(x: x, y: y))
        }

        wavePath.addLine(to: CGPoint(x: width, y: height))
        wavePath.addLine(to: CGPoint(x: 0, y: height))
        wavePath.close()

        context?.setFillColor(firstColor.cgColor)
        context?.addPath(wavePath.cgPath)
        context?.fillPath()
    }

    
    

//

    
}


