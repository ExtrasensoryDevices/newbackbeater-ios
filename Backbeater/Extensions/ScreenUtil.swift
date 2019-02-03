//
//  Constants.swift
//  Backbeater
//
//  Created by Alina Kholcheva on 2018-12-28.
//

/**
 ScreenSize and ScreenSizeClass enums.
 
 IPhone-only applications when run on iPads run in simulated screen.
 iPad Pro 12.9" simulates 375 x 667 (like iPhones 6, 7, 8), other iPads -  320 x 480 (like iPhone 4)
 
 Also note that iPhoneX is .phone5_8inch (bigger than *Plus phones) but is .medium (smaller than *Plus phones)
 */

public enum ScreenSize {
    case phone3_5inch // iPhone 4, iPads except iPad Pro 12.9
    case phone4inch   // iPhone 5
    case phone4_7inch // iPhones 6, 7, 8, iPad Pro 12.9"
    case phone5_5inch // iPhones 6+, 7+, 8+
    case phone5_8inch // iPhones X
    case pad          // should not be there for iphone-only app
}

public enum ScreenSizeClass {
    case xsmall  // 320 x 480 (iPhone 4 )
    case small   // 320 x 568 (iPhone 5)
    case medium  // 375 x 667 (iPhones 6, 7, 8), 375 x 812 (iPhone X)
    case large   // 414 x 736 (iPhones 6+, 7+, 8+)
    case xlarge   // iPads
}

/// A static stateless class providing common tasks for scree size introspection.
public enum ScreenUtil {
    
    public static var screenSize: ScreenSize {
        let screenHeight = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        switch screenHeight {
        case   0...480 : return .phone3_5inch
        case 481...568 : return .phone4inch
        case 569...667 : return .phone4_7inch
        case 668...736 : return .phone5_5inch
        case 737...812 : return .phone5_8inch
        default : return .pad
        }
    }
    
    // TODO: discuss with team re adding a new class .mediumLong (iphone X)
    public static var screenSizeClass: ScreenSizeClass {
        switch screenSize {
        case .phone3_5inch:  // 320 x 480 (iPhone 4)
            return .xsmall
        case .phone4inch:    // 320 x 568 (iPhone 5)
            return .small
        case .phone4_7inch, .phone5_8inch: // 375 x 667 (iPhones 6, 7, 8), 375 x 812 (iPhone X)
            return .medium
        case .phone5_5inch: // 414 x 736 (iPhones 6+, 7+, 8+)
            return .large
        case .pad:
            return .xlarge
        }
    }
    
    // MARK: - Helper methods
    
    /// Returns True is the current device is the same screen size as iPhone 4 & 5, iPads except iPad Pro 12.9
    /// Returns True id device size class is SMALL or XSMALL
    public static var isSmallPhoneSize: Bool {
        let _screenSizeClass = screenSizeClass
        return _screenSizeClass == .xsmall || _screenSizeClass == .small
    }
    
    /// Returns True is the current device is the same screen size as iPhone 6, 7, 8, X
    public static var isMediumPhoneSize: Bool {
        return screenSizeClass == .medium
    }
    
    /// Returns True is the current device is the same screen size as iPhone 6+, 7+, 8+, iPad Pro 12.9"
    public static var isLargePhoneSize: Bool {
        return screenSizeClass == .large
    }
    
    /// Returns True is the current device is the same screen size as iPhone X
    public static var is_iPhoneXSize: Bool {
        return screenSize == .phone5_8inch
    }
    
    /// Returns True is the current device is an iPad. Does not take into account is it a simulated
    public static var is_iPad: Bool {
        let deviceModel = UIDevice.current.model
        let result: Bool = NSString(string: deviceModel).contains("iPad")
        return result
    }
    
    // MARK: - Pixels
    
    /// Returns screen width with scale factor
    public static var screenPixelWidth: NSInteger {
        let mainScreen = UIScreen.main
        return (NSInteger)(mainScreen.bounds.size.width * mainScreen.scale)
    }
    
    /// Returns screen height with scale factor
    public static var screenPixelHeight: NSInteger {
        let mainScreen = UIScreen.main
        return (NSInteger)(mainScreen.bounds.size.height * mainScreen.scale)
    }
    
    private static var mainWindow: UIWindow {
        return ((UIApplication.shared.delegate?.window)!)!
    }
    
}
