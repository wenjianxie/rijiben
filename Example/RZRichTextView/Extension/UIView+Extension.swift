//
//  UIView+Extension.swift
//  camera_magic
//
//  Created by macer on 2024/3/13.
//

import UIKit
import SnapKit
// MARK: - 绘制相关
public extension UIView {
    // 返回视图快照
    @objc var snapshotImage: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// 高性能的异步绘制圆角方法
    /// 原理是创建一个空白的图片，然后替换当前视图layer的contents
    /// 如果另外设置了backgroundColor属性，backgroundColor呈现的的背景颜色不会有圆角效果，需要搭配cornerRadius属性呈现圆角背景色
    /// 此方法指定的bgColor会在backgroundColor上层显示
    ///
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - corners: 圆角作用范围
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    ///   - bgColor: 背景颜色0
    func roundedCorner(radius: CGFloat, corners: UIRectCorner = [.allCorners], borderWidth: CGFloat? = nil, borderColor: UIColor? = nil, bgColor: UIColor) {
        let size = bounds.size
        DispatchQueue.global().async {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            guard let context = UIGraphicsGetCurrentContext() else { return }
            defer { UIGraphicsEndImageContext() }
            if let borderWidth = borderWidth {
                context.setLineWidth(borderWidth)
            }

            if let borderColor = borderColor {
                context.setStrokeColor(borderColor.cgColor)
            } else {
                context.setStrokeColor(UIColor.clear.cgColor)
            }

            context.setFillColor(bgColor.cgColor)

            let halfBorderWidth = borderWidth ?? 0 / 2.0
            let width = size.width
            let height = size.height

            context.move(to: CGPoint(x: width - halfBorderWidth, y: radius + halfBorderWidth))
            if corners.contains(.bottomRight) || corners.contains(.allCorners) {
                // 右下角角度
                context.addArc(tangent1End: CGPoint(x: width - halfBorderWidth, y: height - halfBorderWidth),
                               tangent2End: CGPoint(x: width - radius - halfBorderWidth, y: height - halfBorderWidth), radius: radius)
            } else {
                context.addLine(to: CGPoint(x: width - halfBorderWidth, y: height - halfBorderWidth))
            }

            if corners.contains(.bottomLeft) || corners.contains(.allCorners) {
                // 左下角角度
                context.addArc(tangent1End: CGPoint(x: halfBorderWidth, y: height - halfBorderWidth),
                               tangent2End: CGPoint(x: halfBorderWidth, y: height - radius - halfBorderWidth), radius: radius)
            } else {
                context.addLine(to: CGPoint(x: halfBorderWidth, y: height - halfBorderWidth))
            }

            if corners.contains(.topLeft) || corners.contains(.allCorners) {
                // 左上角角度
                context.addArc(tangent1End: CGPoint(x: halfBorderWidth, y: halfBorderWidth),
                               tangent2End: CGPoint(x: width - halfBorderWidth, y: halfBorderWidth), radius: radius)
            } else {
                context.addLine(to: CGPoint(x: halfBorderWidth, y: halfBorderWidth ))
            }

            if corners.contains(.topRight) || corners.contains(.allCorners) {
                // 右上角角度
                context.addArc(tangent1End: CGPoint(x: width - halfBorderWidth, y: halfBorderWidth),
                               tangent2End: CGPoint(x: width - halfBorderWidth, y: radius + halfBorderWidth), radius: radius)
            } else {
                context.addLine(to: CGPoint(x: width - halfBorderWidth, y: halfBorderWidth))
            }

            context.drawPath(using: .fillStroke)

            if let img = UIGraphicsGetImageFromCurrentImageContext() {
                DispatchQueue.main.async {
                    self.layer.contents = img.cgImage
                }
            }
        }
    }

    /// 包含子视图的快照
    /// drawHierarchy虽然比layer渲染速度快，但是处理超长视图时无法得到其图片，这时需要用Layer的渲染函数来处理。
    ///
    /// - Parameter afterUpdates: true:包含最近的屏幕更新内容 false:不包含刚加入视图层次但未显示的内容
    /// - Returns: 返回快照Image对象，可能为空
    func snapshotImage(afterUpdates: Bool) -> UIImage? {
        if !responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
            return snapshotImage
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        drawHierarchy(in: bounds, afterScreenUpdates: afterUpdates)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // 删除所有的子视图
    func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    /// 返回视图中的第一响应者View
    /// - Returns: 第一响应者的View，可能为空
    func firstResponder() -> UIView? {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        return keyWindow?.firstResponder()
    }

    /// 返回视图的控制器对象
    /// - Returns: 控制器对象，可能为空
    func viewController() -> UIViewController? {
        var view: UIView? = self
        repeat {
            if let nextResponder = view?.next {
                if nextResponder.isKind(of: UIViewController.self) {
                    return nextResponder as? UIViewController
                }
            }
            view = view?.superview
        } while view != nil

        return nil
    }

    /// 返回视图上叠加的alpha值
    /// - Returns: alhpa值
    func visibleAlpha() -> CGFloat {
        if isKind(of: UIWindow.self) {
            if isHidden { return 0 }
            return alpha
        }
        if window == nil { return 0 }
        var alpha: CGFloat = 1
        var tempView: UIView? = self
        while tempView != nil {
            let view = tempView!
            if view.isHidden { alpha = 0; break }
            alpha *= view.alpha
            tempView = view.superview
        }
        return alpha
    }

    /// 添加阴影
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - radius: 半径
    ///   - offset: 偏移
    ///   - opacity: 透明度
    func addShadow(ofColor color: UIColor = UIColor(red: 0.07, green: 0.47, blue: 0.57, alpha: 1.0), radius: CGFloat = 3, offset: CGSize = .zero, opacity: Float = 0.5) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
}

// MARK: - Frame相关
public extension UIView {
    var size: CGSize {
        get { return frame.size }
        set { width = newValue.width; height = newValue.height }
    }

    var width: CGFloat {
        get { return frame.size.width }
        set { return frame.size.width = newValue }
    }

    var height: CGFloat {
        get { return frame.size.height }
        set { return frame.size.height = newValue }
    }

    var x: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }

    var y: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }

    var left: CGFloat {
        get { return x }
        set { x = newValue }
    }

    var top: CGFloat {
        get { return y }
        set { y = newValue }
    }

    var right: CGFloat {
        get { return x + width }
        set { x = newValue - width }
    }

    var bottom: CGFloat {
        get { return y + height }
        set { y = newValue - height }
    }

    var centerX: CGFloat {
        get { return center.x }
        set { center.x = newValue }
    }

    var centerY: CGFloat {
        get { return center.y }
        set { center.y = newValue }
    }

    var origin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }

    var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            layer.borderColor = color.cgColor
        }
    }

    var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
}

protocol ViewChainable {
    
}

extension ViewChainable where Self: UIView {
    @discardableResult
    func config(_ config: (Self)-> Void) -> Self {
        config(self)
        return self
    }
}



//MARK:  Jerry
extension UIView: ViewChainable {
    @discardableResult
    func adhere(toSuperView: UIView) -> Self {
        toSuperView.addSubview(self)
        return self
    }
    
    func insert(to superView: UIView, at index:Int) -> Self {
        superView.insertSubview(self, at: index)
        return self
    }
    
    @discardableResult
    func layout(snapKitMaker: (ConstraintMaker) -> Void) -> Self {
        self.snp.makeConstraints { (make) in
            snapKitMaker(make)
        }
        return self
    }
    
    @discardableResult
    func update(snapKitMaker: (ConstraintMaker) -> Void) -> Self {
        self.snp.updateConstraints { (make) in
            snapKitMaker(make)
        }
        return self
    }
    
    @discardableResult
    func remake(snapKitMaker: (ConstraintMaker) -> Void) -> Self {
        self.snp.remakeConstraints { (make) in
            snapKitMaker(make)
        }
        return self
    }
    
    func getCurrentVC() -> UIViewController? {
        var tempSuper = self.superview
        while tempSuper != nil {
            if let tempNext = tempSuper!.next, tempNext is UIViewController {
                return tempNext as? UIViewController
            }
            tempSuper = tempSuper?.superview
        }
        return nil
    }
    
    /// 部分圆角
        ///
        /// - Parameters:
        ///   - corners: 需要实现为圆角的角，可传入多个
        ///   - radii: 圆角半径
        func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
            let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = maskPath.cgPath
            self.layer.mask = maskLayer
        }
}

extension UIView {
    func addPartialRoundedCorner(radius: CGFloat, corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}


//
//  UITableView+Snp.swift
//
//  Created by shakesVan on 2018/7/19.
//  All rights reserved.
//

import UIKit
import SnapKit

extension UITableView {
    
    /// 设置自动撑开 Header Footer View
    /// - Parameters:
    ///   - headerV: tableView 顶部的view
    ///   - footerV: tableView 底部的view
    public func setupHeaderFooterV(headerV: UIView?, footerV: UIView?) {
        if let headerV = headerV {
            setupHeaderFooterV(&tableHeaderView, contentV: headerV)
        }
        if let footerV = footerV {
            setupHeaderFooterV(&tableFooterView, contentV: footerV)
        }
    }
    
    /// 更新 headerFooterV 的 size
    public func updateHeaderFooterVSize() {
        updateSize(&tableHeaderView)
        updateSize(&tableFooterView)
    }
    /// 设置自动撑开 Header Footer View
    ///
    /// - Parameters:
    ///   - headerFooterV: headerView & FooterView
    ///   - contentV: 内容 （通过约束自动撑开）
    private func setupHeaderFooterV(_ headerFooterV: inout UIView?,
                                    contentV: UIView) {
        let view = UIView()
        view.addSubview(contentV)
        contentV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        headerFooterV = view
        updateSize(&headerFooterV)
    }
    
    /// 更新 headerFooterV 的 size
    ///
    /// - Parameter headerFooterV: 头部尾部的V
    private func updateSize(_ headerFooterV: inout UIView?) {
        guard let view = headerFooterV else { return }
        
        // 需要布局子视图
        view.setNeedsLayout()
        // 立马布局子视图
        view.layoutIfNeeded()
        
        let height = view
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = view.frame
        frame.size.height = height
        view.frame = frame
        // 重新设置tableHeaderView
        headerFooterV = view
    }
}



