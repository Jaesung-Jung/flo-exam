//
//  LyricsView.swift
//  Flo
//
//  Created by 정재성 on 2020/02/08.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import UIKit

final class LyricsView: UIView {
  private let textView = UITextView().then {
    $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    $0.isEditable = false
    $0.isSelectable = false
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
  }

  private var storage: [_Item] = []

  private var attributesStorage: [State: [NSAttributedString.Key: Any]] = [
    .normal: [
      .font: UIFont.systemFont(ofSize: 15),
      .foregroundColor: UIColor.lightGray,
      .paragraphStyle: NSMutableParagraphStyle().then { $0.alignment = .center }
    ],
    .highlighted: [
      .font: UIFont.systemFont(ofSize: 15, weight: .heavy),
      .foregroundColor: UIColor.darkGray,
      .paragraphStyle: NSMutableParagraphStyle().then { $0.alignment = .center }
    ]
  ]

  private var itemIndexForTime: ((TimeInterval) -> Int?)?

  private var highlightedIndex: Int?

  let tapGestureRecognizer = UITapGestureRecognizer()

  weak var delegate: LyricsViewDelegate?

  var autoScrolling: Bool = true

  var textAlignment: NSTextAlignment? {
    get { (attributesStorage[.normal]?[.paragraphStyle] as? NSParagraphStyle)?.alignment }
    set {
      attributesStorage.forEach { element in
        (element.value[.paragraphStyle] as? NSMutableParagraphStyle)?.alignment = newValue ?? .center
      }
      _updateTextAttributes(text: nil, highlightedIndex: highlightedIndex)
    }
  }

  var textInsets: UIEdgeInsets {
    get { textView.textContainerInset }
    set { textView.textContainerInset = newValue }
  }

  var playbackTime: TimeInterval = 0 {
    didSet {
      let itemIndex = itemIndexForTime?(playbackTime)
      if highlightedIndex != itemIndex {
        _updateTextAttributes(text: nil, highlightedIndex: itemIndex)
        _scrollToIndex(itemIndex)
        highlightedIndex = itemIndex
      }
    }
  }

  func setTextColor(_ color: UIColor, for state: State) {
    attributesStorage[state]?[.foregroundColor] = color
  }

  func setFont(_ font: UIFont, for state: State) {
    attributesStorage[state]?[.font] = font
  }

  var lyrics: Lyrics? {
    didSet {
      if let lyrics = lyrics {
        storage = lyrics.contents.reduce(into: [_Item]()) { items, content in
          let text = "\(content.text)\n\n"
          items.append(_Item(
            time: content.timeInterval,
            text: text,
            range: NSRange(location: items.last?.range.upperBound ?? 0, length: text.count)
          ))
        }
        itemIndexForTime = memoize { [storage] (time: TimeInterval) -> Int? in // memoization으로 검색성능 향상
          guard let index = storage.reversed().firstIndex(where: { $0.time <= time })?.base else {
            return nil
          }
          return storage.index(before: index)
        }
      } else {
        storage = []
        itemIndexForTime = nil
      }
      highlightedIndex = nil
      _updateText()
    }
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    _setup()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    _setup()
  }
}

extension LyricsView {
  enum State {
    case normal
    case highlighted
  }
}

extension LyricsView {
  private func _setup() {
    addSubview(textView)
    textView.addGestureRecognizer(tapGestureRecognizer)
    tapGestureRecognizer.addTarget(self, action: #selector(_handleTapGesture(_:)))
  }

  private func _updateText() {
    _updateTextAttributes(text: storage.map { $0.text }.joined(), highlightedIndex: highlightedIndex)
  }

  private func _updateTextAttributes(text: String?, highlightedIndex: Int?) {
    let attributedString = NSMutableAttributedString(string: text ?? textView.text)
    attributedString.setAttributes(attributesStorage[.normal], range: NSRange(location: 0, length: attributedString.length))
    if let index = highlightedIndex {
      attributedString.setAttributes(attributesStorage[.highlighted], range: storage[index].range)
    }
    textView.attributedText = attributedString
  }

  private func _scrollToIndex(_ index: Int?) {
    guard let index = index, autoScrolling else {
      return
    }
    textView.scrollRangeToVisible(storage[index].range)
  }

  @objc private func _handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
    guard let characterRange = textView.characterRange(at: gestureRecognizer.location(in: gestureRecognizer.view)) else {
      return
    }
    let location = textView.offset(from: textView.beginningOfDocument, to: characterRange.start)
    guard let item = storage.first(where: { NSLocationInRange(location, $0.range) }) else {
      return
    }
    delegate?.lyricsView?(self, didSelectText: item.text, range: item.range, time: item.time)
  }
}

// MARK: - LyricsView._Item

extension LyricsView {
  private struct _Item {
    let time: TimeInterval
    let text: String
    let range: NSRange
  }
}

// MARK: - LyricsViewDelegate

@objc protocol LyricsViewDelegate: NSObjectProtocol {
  @objc optional func lyricsView(_ lyricsView: LyricsView, didSelectText text: String, range: NSRange, time: TimeInterval)
}

// MARK: - Reactive Extension

#if canImport(RxSwift) && canImport(RxCocoa)

import RxSwift
import RxCocoa

extension Reactive where Base: LyricsView {
  var delegate: DelegateProxy<LyricsView, LyricsViewDelegate> {
    return RxLyricsViewDelegateProxy.proxy(for: base)
  }

  var didSelectText: Observable<(text: String, range: NSRange, time: TimeInterval)> {
    return delegate
      .methodInvoked(#selector(LyricsViewDelegate.lyricsView(_:didSelectText:range:time:)))
      .flatMap { args -> Observable<(text: String, range: NSRange, time: TimeInterval)> in
        guard let text = args[1] as? String, let range = args[2] as? NSRange, let time = args[3] as? TimeInterval else {
          return .empty()
        }
        return .just((text: text, range: range, time: time))
      }
  }

  var lyrics: Binder<Lyrics?> {
    return Binder(base) { view, lyrics in
      view.lyrics = lyrics
    }
  }

  var playbackTime: Binder<TimeInterval> {
    return Binder(base) { view, time in
      view.playbackTime = time
    }
  }
}

class RxLyricsViewDelegateProxy: DelegateProxy<LyricsView, LyricsViewDelegate>, DelegateProxyType, LyricsViewDelegate {
  static func registerKnownImplementations() {
    register {
      RxLyricsViewDelegateProxy(parentObject: $0, delegateProxy: self)
    }
  }

  static func currentDelegate(for object: LyricsView) -> LyricsViewDelegate? {
    return object.delegate
  }

  static func setCurrentDelegate(_ delegate: LyricsViewDelegate?, to object: LyricsView) {
    object.delegate = delegate
  }
}

#endif

#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 13.0, *)
struct LyricsViewPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      LyricsView().then {
        $0.lyrics = Lyrics(string: "[00:16:200]we wish you a merry christmas\n[00:18:300]we wish you a merry christmas\n[00:21:100]we wish you a merry christmas\n[00:23:600]and a happy new year\n[00:26:300]we wish you a merry christmas\n[00:28:700]we wish you a merry christmas\n[00:31:400]we wish you a merry christmas\n[00:33:600]and a happy new year\n[00:36:500]good tidings we bring\n[00:38:900]to you and your kin\n[00:41:500]good tidings for christmas\n[00:44:200]and a happy new year\n[00:46:600]Oh, bring us some figgy pudding\n[00:49:300]Oh, bring us some figgy pudding\n[00:52:200]Oh, bring us some figgy pudding\n[00:54:500]And bring it right here\n[00:57:000]Good tidings we bring \n[00:59:700]to you and your kin\n[01:02:100]Good tidings for Christmas \n[01:04:800]and a happy new year\n[01:07:400]we wish you a merry christmas\n[01:10:000]we wish you a merry christmas\n[01:12:500]we wish you a merry christmas\n[01:15:000]and a happy new year\n[01:17:700]We won't go until we get some\n[01:20:200]We won't go until we get some\n[01:22:800]We won't go until we get some\n[01:25:300]So bring some out here\n[01:29:800]연주\n[02:11:900]Good tidings we bring \n[02:14:000]to you and your kin\n[02:16:500]good tidings for christmas\n[02:19:400]and a happy new year\n[02:22:000]we wish you a merry christmas\n[02:24:400]we wish you a merry christmas\n[02:27:000]we wish you a merry christmas\n[02:29:600]and a happy new year\n[02:32:200]Good tidings we bring \n[02:34:500]to you and your kin\n[02:37:200]Good tidings for Christmas \n[02:40:000]and a happy new year\n[02:42:400]Oh, bring us some figgy pudding\n[02:45:000]Oh, bring us some figgy pudding\n[02:47:600]Oh, bring us some figgy pudding\n[02:50:200]And bring it right here\n[02:52:600]we wish you a merry christmas\n[02:55:300]we wish you a merry christmas\n[02:57:900]we wish you a merry christmas\n[03:00:500]and a happy new year") // swiftlint:disable:this line_length
        $0.playbackTime = 30
      }
    }
  }
}

#endif
