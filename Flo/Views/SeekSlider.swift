//
//  SeekSlider.swift
//  Flo
//
//  Created by 정재성 on 2020/02/03.
//  Copyright © 2020 Jaesung Jung. All rights reserved.
//

import UIKit

final class SeekSlider: UIControl {
  private let thumbSize = CGSize(width: 20, height: 20)
  private let trackSize = CGSize(width: 0, height: 2)
  private let hitTestSlop = UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15)

  private let trackLayer = CALayer()
  private let progressLayer = CALayer()
  private let sliderLayer = CALayer()
  private let thumbLayer = CALayer().then {
    $0.shadowColor = UIColor.darkGray.cgColor
    $0.shadowOffset = CGSize(width: 1, height: 2)
    $0.shadowOpacity = 0.5
    $0.shadowRadius = 1
    $0.setAffineTransform($0.affineTransform().scaledBy(x: 0, y: 0))
  }

  private(set) var progress: Float = 0
  private(set) var sliderValue: Float = 0

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    _setup()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    _setup()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    trackLayer.frame = _trackFrame(in: bounds)
    progressLayer.frame = _frame(in: bounds, fraction: max(0.0, min(1.0, CGFloat(progress))))

    let value = max(0.0, min(1.0, CGFloat(sliderValue)))
    sliderLayer.frame = _frame(in: bounds, fraction: value)
    thumbLayer.frame = _thumbFrame(in: bounds, fraction: value)
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: bounds.width, height: thumbSize.height)
  }

  func setProgress(_ progress: Float, animated: Bool) {
    self.progress = progress
    setNeedsLayout()
    CATransaction.begin()
    CATransaction.setValue(animated ? kCFBooleanFalse : kCFBooleanTrue, forKey: kCATransactionDisableActions)
    layoutIfNeeded()
    CATransaction.commit()
  }

  func setSliderValue(_ value: Float, animated: Bool) {
    self.sliderValue = value
    setNeedsLayout()
    CATransaction.begin()
    CATransaction.setValue(animated ? kCFBooleanFalse : kCFBooleanTrue, forKey: kCATransactionDisableActions)
    layoutIfNeeded()
    CATransaction.commit()
  }

  override func tintColorDidChange() {
    sliderLayer.backgroundColor = tintColor.cgColor
    thumbLayer.backgroundColor = tintColor.cgColor
  }
}

extension SeekSlider {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    return thumbLayer.frame.inset(by: hitTestSlop).contains(point) ? self : nil
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    thumbLayer.setAffineTransform(.identity)
    sendActions(for: .editingDidBegin)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let location = touch.location(in: touch.view)
    let x = max(trackLayer.frame.minX, min(trackLayer.frame.maxX, location.x))
    let newValue = x / trackLayer.frame.maxX

    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    sliderLayer.frame = _frame(in: bounds, fraction: newValue)
    thumbLayer.frame = _thumbFrame(in: bounds, fraction: newValue)
    CATransaction.commit()

    if sliderValue != Float(newValue) {
      sliderValue = Float(newValue)
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    thumbLayer.setAffineTransform(thumbLayer.affineTransform().scaledBy(x: 0, y: 0))
    sendActions(for: .valueChanged)
    sendActions(for: .editingDidEnd)
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    thumbLayer.setAffineTransform(thumbLayer.affineTransform().scaledBy(x: 0, y: 0))
    sendActions(for: .valueChanged)
    sendActions(for: .editingDidEnd)
  }
}

extension SeekSlider {
  private func _setup() {
    layer.addSublayer(trackLayer)
    layer.addSublayer(progressLayer)
    layer.addSublayer(sliderLayer)
    layer.addSublayer(thumbLayer)

    trackLayer.cornerRadius = trackSize.height * 0.5
    progressLayer.cornerRadius = trackSize.height * 0.5
    sliderLayer.cornerRadius = trackSize.height * 0.5
    thumbLayer.cornerRadius = thumbSize.height * 0.5

    trackLayer.backgroundColor = #colorLiteral(red: 0.8039280772, green: 0.8040639162, blue: 0.8039101958, alpha: 0.3021566901).cgColor
    progressLayer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
    sliderLayer.backgroundColor = tintColor.cgColor
    thumbLayer.backgroundColor = tintColor.cgColor
  }

  private func _trackFrame(in bounds: CGRect) -> CGRect {
    return CGRect(
      x: bounds.minX,
      y: bounds.midY - self.trackSize.height * 0.5,
      width: bounds.width,
      height: self.trackSize.height
    )
  }

  private func _frame(in bounds: CGRect, fraction: CGFloat) -> CGRect {
    let trackFrame = _trackFrame(in: bounds)
    return CGRect(
      x: trackFrame.minX,
      y: trackFrame.minY,
      width: trackFrame.width * fraction,
      height: trackFrame.height
    )
  }

  private func _thumbFrame(in bounds: CGRect, fraction: CGFloat) -> CGRect {
    let trackFrame = _trackFrame(in: bounds)
    return CGRect(
      x: trackFrame.width * fraction + trackFrame.minX - thumbSize.width * 0.5,
      y: trackFrame.midY - thumbSize.height * 0.5,
      width: thumbSize.width,
      height: thumbSize.height
    )
  }
}

#if canImport(RxSwift) && canImport(RxCocoa)

import RxSwift
import RxCocoa

extension Reactive where Base: SeekSlider {
  var beginEditing: ControlEvent<Void> {
    return base.rx.controlEvent(.editingDidBegin)
  }

  var endEditing: ControlEvent<Void> {
    return base.rx.controlEvent(.editingDidEnd)
  }

  var progress: Binder<Float> {
    return Binder(base) { slider, progress in
      slider.setProgress(progress, animated: false)
    }
  }

  var sliderValue: ControlProperty<Float> {
    return sliderValue(animated: false)
  }

  func sliderValue(animated: Bool) -> ControlProperty<Float> {
    return controlProperty(
      editingEvents: .valueChanged,
      getter: { $0.sliderValue },
      setter: { $0.setSliderValue($1, animated: animated) }
    )
  }
}

#endif

#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 13.0, *)
struct SeekSliderPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      SeekSlider(frame: CGRect(x: 0, y: 0, width: 320, height: 40)).then {
        $0.setSliderValue(0.5, animated: false)
      }
    }
    .padding(20)
    .previewLayout(.sizeThatFits)
  }
}

#endif
