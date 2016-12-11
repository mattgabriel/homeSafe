//
//  Design.swift
//  Autonome
//
//  Created by Matt Gabriel on 10/12/2016.
//  Copyright © 2016 Matt Gabriel. All rights reserved.
//

import Foundation
import UIKit


class Design {
    
    struct Dimension {
        static let recordButtonSize: CGFloat = 75.0
        static let mainContentWidth: CGFloat = 620.0
        static let paddingText: CGFloat = 20.0
        static let recordButtonPaddding: CGFloat = 20.0
    }
    
    
    struct Color {
        static let lighterGray = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1.0)
        static let lightGray = UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1.0)
        static let mediumGray = UIColor(red: 150 / 255, green: 150 / 255, blue: 150 / 255, alpha: 1.0)
        static let darkGray = UIColor(red: 95 / 255, green: 95 / 255, blue: 95 / 255, alpha: 1.0)
        static let darkerGray = UIColor(red: 50 / 255, green: 50 / 255, blue: 50 / 255, alpha: 1.0)
        static let darkestGray = UIColor(red: 35 / 255, green: 35 / 255, blue: 35 / 255, alpha: 1.0)
        static let red = UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1.0)
        static let darkOrange = UIColor(red: 158 / 255, green: 5 / 255, blue: 13 / 255, alpha: 1.0)
        static let green = UIColor(red: 51 / 255, green: 198 / 255, blue: 36 / 255, alpha: 1.0)
        static let blue = UIColor(red: 0 / 255, green: 100 / 255, blue: 229 / 255, alpha: 1.0)
        static let black = UIColor(red: 25 / 255, green: 25 / 255, blue: 25 / 255, alpha: 1.0)
        static let realBlack = UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1.0)
        static let error = UIColor(red: 180 / 255, green: 50 / 255, blue: 17 / 255, alpha: 1.0)
        static let error2 = UIColor(red: 255 / 255, green: 210 / 255, blue: 199 / 255, alpha: 1.0)
    }
    
    
    struct Font {
        static let superSize = UIFont.init(name: "HelveticaNeue-Bold", size: 160)
        static let superSizeSmall = UIFont.init(name: "HelveticaNeue-Bold", size: 34)
        static let commonLight = UIFont.init(name: "HelveticaNeue-light", size: 18)
        static let commonBold = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
        static let tiny = UIFont.init(name: "HelveticaNeue-light", size: 12)
        static let titles = UIFont.init(name: "HelveticaNeue-light", size: 50)
        static let titlesBold = UIFont.init(name: "HelveticaNeue-Bold", size: 24)
        static let titlesSmall = UIFont.init(name: "HelveticaNeue-light", size: 30)
        static let subtitles = UIFont.init(name: "HelveticaNeue-light", size: 16)
        static let subtitlesSmall = UIFont.init(name: "HelveticaNeue-light", size: 16)
        static let largeSubtitles = UIFont.init(name: "HelveticaNeue-light", size: 20)
    }
    
    
    
}
