//
//  AppDelegate.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  private let dependency: AppDependencyProtocol

  var window: UIWindow?

  override init() {
    let isTesting = NSClassFromString("XCTestCase") != nil
    dependency = isTesting ? TestDependency() : AppDependency()
    super.init()
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = dependency.resolve()
    return true
  }
}
