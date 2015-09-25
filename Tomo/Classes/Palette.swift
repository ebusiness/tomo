//
//  Palette.swift
//  Tomo
//
//  Created by ebuser on 2015/09/24.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

enum Palette: Int {
    
    case Red
    case Pink
    case Purple
    case DeepPurple
    case Indigo
    case Blue
    case LightBlue
    case Cyan
    case Teal
    case Green
    case LightGreen
    case Lime
    case Yellow
    case Amber
    case Orange
    case DeepOrange
    case Brown
    case Grey
    case BlueGrey
    
    init(index: Int) {
        let enumIndex = index % 19
        self = Palette(rawValue: enumIndex)!
    }
    
    func getDarkPrimaryColor() -> UIColor {
        switch self {
        case Red:
            return Util.UIColorFromRGB(0xD32F2F, alpha: 1.0)
        case Pink:
            return Util.UIColorFromRGB(0xC2185B, alpha: 1.0)
        case Purple:
            return Util.UIColorFromRGB(0x7B1FA2, alpha: 1.0)
        case DeepPurple:
            return Util.UIColorFromRGB(0x512DA8, alpha: 1.0)
        case Indigo:
            return Util.UIColorFromRGB(0x303F9F, alpha: 1.0)
        case Blue:
            return Util.UIColorFromRGB(0x1976D2, alpha: 1.0)
        case LightBlue:
            return Util.UIColorFromRGB(0x0288D1, alpha: 1.0)
        case Cyan:
            return Util.UIColorFromRGB(0x0097A7, alpha: 1.0)
        case Teal:
            return Util.UIColorFromRGB(0x00796B, alpha: 1.0)
        case Green:
            return Util.UIColorFromRGB(0x388E3C, alpha: 1.0)
        case LightGreen:
            return Util.UIColorFromRGB(0x689F38, alpha: 1.0)
        case Lime:
            return Util.UIColorFromRGB(0xAFB42B, alpha: 1.0)
        case Yellow:
            return Util.UIColorFromRGB(0xFBC02D, alpha: 1.0)
        case Amber:
            return Util.UIColorFromRGB(0xFFA000, alpha: 1.0)
        case Orange:
            return Util.UIColorFromRGB(0xF57C00, alpha: 1.0)
        case DeepOrange:
            return Util.UIColorFromRGB(0xE64A19, alpha: 1.0)
        case Brown:
            return Util.UIColorFromRGB(0x5D4037, alpha: 1.0)
        case Grey:
            return Util.UIColorFromRGB(0x616161, alpha: 1.0)
        case BlueGrey:
            return Util.UIColorFromRGB(0x455A64, alpha: 1.0)
        }
    }
    
    func getPrimaryColor() -> UIColor {
        switch self {
        case Red:
            return Util.UIColorFromRGB(0xF44336, alpha: 1.0)
        case Pink:
            return Util.UIColorFromRGB(0xE91E63, alpha: 1.0)
        case Purple:
            return Util.UIColorFromRGB(0x9C27B0, alpha: 1.0)
        case DeepPurple:
            return Util.UIColorFromRGB(0x673AB7, alpha: 1.0)
        case Indigo:
            return Util.UIColorFromRGB(0x3F51B5, alpha: 1.0)
        case Blue:
            return Util.UIColorFromRGB(0x2196F3, alpha: 1.0)
        case LightBlue:
            return Util.UIColorFromRGB(0x03A9F4, alpha: 1.0)
        case Cyan:
            return Util.UIColorFromRGB(0x00BCD4, alpha: 1.0)
        case Teal:
            return Util.UIColorFromRGB(0x009688, alpha: 1.0)
        case Green:
            return Util.UIColorFromRGB(0x4CAF50, alpha: 1.0)
        case LightGreen:
            return Util.UIColorFromRGB(0x8BC34A, alpha: 1.0)
        case Lime:
            return Util.UIColorFromRGB(0xCDDC39, alpha: 1.0)
        case Yellow:
            return Util.UIColorFromRGB(0xFFEB3B, alpha: 1.0)
        case Amber:
            return Util.UIColorFromRGB(0xFFC107, alpha: 1.0)
        case Orange:
            return Util.UIColorFromRGB(0xFF9800, alpha: 1.0)
        case DeepOrange:
            return Util.UIColorFromRGB(0xFF5722, alpha: 1.0)
        case Brown:
            return Util.UIColorFromRGB(0x795548, alpha: 1.0)
        case Grey:
            return Util.UIColorFromRGB(0x9E9E9E, alpha: 1.0)
        case BlueGrey:
            return Util.UIColorFromRGB(0x607D8B, alpha: 1.0)
        }
    }
    
    func getLightPrimaryColor() -> UIColor {
        switch self {
        case Red:
            return Util.UIColorFromRGB(0xFFCDD2, alpha: 1.0)
        case Pink:
            return Util.UIColorFromRGB(0xF8BBD0, alpha: 1.0)
        case Purple:
            return Util.UIColorFromRGB(0xE1BEE7, alpha: 1.0)
        case DeepPurple:
            return Util.UIColorFromRGB(0xD1C4E9, alpha: 1.0)
        case Indigo:
            return Util.UIColorFromRGB(0xC5CAE9, alpha: 1.0)
        case Blue:
            return Util.UIColorFromRGB(0xBBDEFB, alpha: 1.0)
        case LightBlue:
            return Util.UIColorFromRGB(0xB3E5FC, alpha: 1.0)
        case Cyan:
            return Util.UIColorFromRGB(0xB2EBF2, alpha: 1.0)
        case Teal:
            return Util.UIColorFromRGB(0xB2DFDB, alpha: 1.0)
        case Green:
            return Util.UIColorFromRGB(0xC8E6C9, alpha: 1.0)
        case LightGreen:
            return Util.UIColorFromRGB(0xDCEDC8, alpha: 1.0)
        case Lime:
            return Util.UIColorFromRGB(0xF0F4C3, alpha: 1.0)
        case Yellow:
            return Util.UIColorFromRGB(0xFFF9C4, alpha: 1.0)
        case Amber:
            return Util.UIColorFromRGB(0xFFECB3, alpha: 1.0)
        case Orange:
            return Util.UIColorFromRGB(0xFFE0B2, alpha: 1.0)
        case DeepOrange:
            return Util.UIColorFromRGB(0xFFCCBC, alpha: 1.0)
        case Brown:
            return Util.UIColorFromRGB(0xD7CCC8, alpha: 1.0)
        case Grey:
            return Util.UIColorFromRGB(0xF5F5F5, alpha: 1.0)
        case BlueGrey:
            return Util.UIColorFromRGB(0xCFD8DC, alpha: 1.0)
        }
    }
    
    func getAccentColor() -> UIColor {
        switch self {
        case Red:
            return Util.UIColorFromRGB(0xFF5252, alpha: 1.0)
        case Pink:
            return Util.UIColorFromRGB(0xFF4081, alpha: 1.0)
        case Purple:
            return Util.UIColorFromRGB(0xE040FB, alpha: 1.0)
        case DeepPurple:
            return Util.UIColorFromRGB(0x7C4DFF, alpha: 1.0)
        case Indigo:
            return Util.UIColorFromRGB(0x536DFE, alpha: 1.0)
        case Blue:
            return Util.UIColorFromRGB(0x448AFF, alpha: 1.0)
        case LightBlue:
            return Util.UIColorFromRGB(0x03A9F4, alpha: 1.0)
        case Cyan:
            return Util.UIColorFromRGB(0x00BCD4, alpha: 1.0)
        case Teal:
            return Util.UIColorFromRGB(0x009688, alpha: 1.0)
        case Green:
            return Util.UIColorFromRGB(0x4CAF50, alpha: 1.0)
        case LightGreen:
            return Util.UIColorFromRGB(0x8BC34A, alpha: 1.0)
        case Lime:
            return Util.UIColorFromRGB(0xCDDC39, alpha: 1.0)
        case Yellow:
            return Util.UIColorFromRGB(0xFFEB3B, alpha: 1.0)
        case Amber:
            return Util.UIColorFromRGB(0xFFC107, alpha: 1.0)
        case Orange:
            return Util.UIColorFromRGB(0xFF9800, alpha: 1.0)
        case DeepOrange:
            return Util.UIColorFromRGB(0xFF5722, alpha: 1.0)
        case Brown:
            return Util.UIColorFromRGB(0x795548, alpha: 1.0)
        case Grey:
            return Util.UIColorFromRGB(0x9E9E9E, alpha: 1.0)
        case BlueGrey:
            return Util.UIColorFromRGB(0x607D8B, alpha: 1.0)
        }
    }
    
    func getTextIconColor() -> UIColor {
        switch self {
        case LightGreen, Lime, Yellow, Amber, Orange, Grey:
            return Util.UIColorFromRGB(0x212121, alpha: 1.0)
        default:
            return Util.UIColorFromRGB(0xFFFFFF, alpha: 1.0)
        }
    }
    
    func getPrimaryTextColor() -> UIColor {
        return Util.UIColorFromRGB(0x212121, alpha: 1.0)
    }
    
    func getSecondaryTextColor() -> UIColor {
        return Util.UIColorFromRGB(0x727272, alpha: 1.0)
    }
    
    func getDividerColor() -> UIColor {
        return Util.UIColorFromRGB(0xB6B6B6, alpha: 1.0)
    }
}