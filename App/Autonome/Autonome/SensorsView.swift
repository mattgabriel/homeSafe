//
//  SensorsView.swift
//  Autonome
//
//  Created by Matt Gabriel on 10/12/2016.
//  Copyright © 2016 Matt Gabriel. All rights reserved.
//

import UIKit

protocol SensorViewProtocol {
    func buttonTapped()
}

class SensorsView: UIView {
    
    var delegate: SensorViewProtocol?
    //views
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
    }
    
    fileprivate func initViews() {
        let centerLine = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 1))
        centerLine.backgroundColor = UIColor.white
        centerLine.alpha = 0.5
        self.addSubview(centerLine)
        
        let centerLine1 = UIView(frame: CGRect(x: frame.size.width/2, y: 0, width: 1, height: frame.size.height))
        centerLine1.backgroundColor = UIColor.white
        centerLine1.alpha = 0.5
        self.addSubview(centerLine1)
    }
    
    func tapped(sender: UIButton){
        delegate?.buttonTapped()
    }
    
    func addButton(){
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        btn.addTarget(self, action: #selector(self.tapped(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(btn)
    }
    
    func buildSquare(title: String, value: String, col: Int, row: Int, isBad: Bool = false){
        let boxW = frame.size.width/2
        let boxH = frame.size.height/3
        
        let box = UIView(frame: CGRect(x: CGFloat(col)*boxW, y: CGFloat(row)*boxH, width: boxW, height: boxH))
        if isBad {
            box.backgroundColor = Design.Color.darkerGray
        }
        self.addSubview(box)
        
        let boxLine = UIView(frame: CGRect(x: 0, y: boxH-1, width: boxW, height: 1))
        boxLine.backgroundColor = UIColor.white
        boxLine.alpha = 0.5
        box.addSubview(boxLine)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: boxH-55, width: boxW, height: 25))
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.font = Design.Font.subtitles
        titleLabel.text = title
        box.addSubview(titleLabel)
        
        let valueLabel = UILabel(frame: CGRect(x: 0, y: 14, width: boxW, height: 80))
        valueLabel.textColor = UIColor.white
        valueLabel.textAlignment = .center
        valueLabel.font = Design.Font.titles
        valueLabel.text = value
        box.addSubview(valueLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
