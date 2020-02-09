//
//  AppDependency.swift
//  Flo
//
//  Created by 정재성 on 2020/01/31.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import UIKit

protocol AppDependencyProtocol {
  func resolve() -> UIWindow
}

struct AppDependency: AppDependencyProtocol {
  func resolve() -> UIWindow {
    let window = UIWindow()
    let musicRepository = MusicRepository(
      baseURL: URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com")!, // swiftlint:disable:this force_unwrapping
      session: URLSession(configuration: .default),
      decoder: JSONDecoder()
    )
    let audioPlayer = AudioPlayer()

    let playerViewFactory = Factory<Void, UIViewController> {
      return PlayerViewController().then {
        $0.reactor = PlayerViewReactor(
          repository: musicRepository,
          player: audioPlayer
        )
        $0.lyricsViewFactory = Factory { lyrics in
          LyricsViewController().then {
            $0.reactor = LyricsViewReactor(player: audioPlayer, lyrics: lyrics)
          }
        }
      }
    }

    let splashViewFactory = Factory<Void, UIViewController> {
      return SplashViewController().then {
        $0.didFinishLoading = { [weak window] in
          window?.rootViewController = playerViewFactory.create(())
        }
      }
    }

    window.rootViewController = splashViewFactory.create(())
    window.makeKeyAndVisible()
    return window
  }
}

struct TestDependency: AppDependencyProtocol {
  func resolve() -> UIWindow {
    return UIWindow().then {
      $0.makeKeyAndVisible()
      $0.rootViewController = UIViewController()
    }
  }
}
