//
//  MapView.swift
//  Autonome
//
//  Created by Matt Gabriel on 11/12/2016.
//  Copyright © 2016 Matt Gabriel. All rights reserved.
//

import UIKit

protocol MapViewProtocol {
    func button1Tapped()
    func button2Tapped()
    func buttonHiddenTapped()
}

class MapView: UIView {
    
    var delegate: MapViewProtocol?
    //views
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
    }
    
    //https://conapp.acceptatie.politie.nl/v1/stations?uid=12ce71b0-ea05-454d-8965-7e9216081822&lat=51.922822&lon=4.469350
    //https://conapp.acceptatie.politie.nl/v1/overview?sections=S&lat=51.922822&lon=4.469350
    
    fileprivate func initViews() {
        let image = UIImageView(frame: CGRect(x: -75, y: 0, width: frame.size.width+150, height: frame.size.height))
        image.image = UIImage(named: "map.png")
        image.contentMode = .scaleAspectFit
        self.addSubview(image)
        
        let btn1 = UIButton(frame: CGRect(x: 0, y: frame.size.height-90, width: frame.size.width/2, height: 90))
        btn1.backgroundColor = Design.Color.darkerGray
        btn1.setTitle("Call Home", for: UIControlState.normal)
        btn1.addTarget(self, action: #selector(self.button1(sender:)), for: UIControlEvents.touchUpInside)
        btn1.titleLabel?.font = Design.Font.commonBold
        self.addSubview(btn1)
        
        let btn2 = UIButton(frame: CGRect(x: frame.size.width/2, y: frame.size.height-90, width: frame.size.width/2, height: 90))
        btn2.backgroundColor = Design.Color.green
        btn2.setTitle("Call Police", for: UIControlState.normal)
        btn2.addTarget(self, action: #selector(self.button2(sender:)), for: UIControlEvents.touchUpInside)
        btn2.titleLabel?.font = Design.Font.commonBold
        self.addSubview(btn2)
        
        let btnHidden = UIButton(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 300))
        btnHidden.addTarget(self, action: #selector(self.buttonHidden(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(btnHidden)
        
    }
    
    func button1(sender: UIButton){
        delegate?.button1Tapped()
    }
    
    func button2(sender: UIButton){
        delegate?.button2Tapped()
    }
    
    func buttonHidden(sender: UIButton){
        delegate?.buttonHiddenTapped()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
