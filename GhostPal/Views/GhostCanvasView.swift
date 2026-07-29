import SwiftUI

/// Procedural SwiftUI Canvas View rendering the cute, spooky ghost with animated states, thought bubbles, and FX.
struct GhostCanvasView: View {
    let state: GhostState
    let facingDirection: FacingDirection
    let animationTime: Double
    let eyeOffsetX: CGFloat
    let headTiltAngle: Double
    let flipAngle: Double
    let currentEmoji: String?
    let isNightMode: Bool
    
    init(
        state: GhostState,
        facingDirection: FacingDirection,
        animationTime: Double,
        eyeOffsetX: CGFloat = 0.0,
        headTiltAngle: Double = 0.0,
        flipAngle: Double = 0.0,
        currentEmoji: String? = nil,
        isNightMode: Bool = false
    ) {
        self.state = state
        self.facingDirection = facingDirection
        self.animationTime = animationTime
        self.eyeOffsetX = eyeOffsetX
        self.headTiltAngle = headTiltAngle
        self.flipAngle = flipAngle
        self.currentEmoji = currentEmoji
        self.isNightMode = isNightMode
    }
    
    var body: some View {
        ZStack {
            // Item 4: Nighttime / Dark Mode Spectral Aura Glow
            if isNightMode {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.6, green: 0.35, blue: 1.0).opacity(0.45),
                                Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 55
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)
                
                WillOWispParticlesView(animationTime: animationTime)
            }
            
            // Main Ghost Canvas
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let center = CGPoint(x: w / 2, y: h / 2 + 5)
                
                // 1. Draw Body Shadow
                var shadowPath = Path()
                shadowPath.addEllipse(in: CGRect(x: center.x - 22, y: h - 14, width: 44, height: 10))
                context.fill(shadowPath, with: .color(Color.black.opacity(state.isSleeping ? 0.25 : 0.12)))
                
                context.withCGContext { cgContext in
                    let totalRotation = (flipAngle + headTiltAngle) * .pi / 180.0
                    if totalRotation != 0.0 {
                        cgContext.translateBy(x: center.x, y: center.y)
                        cgContext.rotate(by: totalRotation)
                        cgContext.translateBy(x: -center.x, y: -center.y)
                    }
                    
                    // 2. Ghost Body Path
                    let bodyRect = CGRect(x: center.x - 26, y: center.y - 32, width: 52, height: 56)
                    var bodyPath = Path()
                    
                    let headRadius: CGFloat = 26
                    let headCenter = CGPoint(x: center.x, y: bodyRect.minY + headRadius)
                    bodyPath.addArc(center: headCenter, radius: headRadius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    
                    bodyPath.addLine(to: CGPoint(x: headCenter.x + headRadius, y: bodyRect.maxY - 10))
                    
                    let skirtY = bodyRect.maxY - 4
                    let flutter = sin(animationTime * 4) * 2.0
                    
                    bodyPath.addQuadCurve(
                        to: CGPoint(x: headCenter.x + 9, y: skirtY + flutter),
                        control: CGPoint(x: headCenter.x + 18, y: skirtY + 8 - flutter)
                    )
                    bodyPath.addQuadCurve(
                        to: CGPoint(x: headCenter.x - 9, y: skirtY - flutter),
                        control: CGPoint(x: headCenter.x, y: skirtY + 9 + flutter)
                    )
                    bodyPath.addQuadCurve(
                        to: CGPoint(x: headCenter.x - headRadius, y: skirtY - 10),
                        control: CGPoint(x: headCenter.x - 18, y: skirtY + 8 - flutter)
                    )
                    
                    bodyPath.addLine(to: CGPoint(x: headCenter.x - headRadius, y: headCenter.y))
                    bodyPath.closeSubpath()
                    
                    let ghostGradient = Gradient(colors: isNightMode ? [
                        Color(red: 0.96, green: 0.98, blue: 1.0),
                        Color(red: 0.82, green: 0.88, blue: 1.0)
                    ] : [
                        Color(red: 0.98, green: 0.99, blue: 1.0),
                        Color(red: 0.91, green: 0.93, blue: 0.98)
                    ])
                    
                    context.fill(
                        bodyPath,
                        with: .linearGradient(
                            ghostGradient,
                            startPoint: CGPoint(x: center.x, y: bodyRect.minY),
                            endPoint: CGPoint(x: center.x, y: bodyRect.maxY)
                        )
                    )
                    
                    let outlineColor = isNightMode ? Color(red: 0.4, green: 0.7, blue: 1.0).opacity(0.4) : Color.blue.opacity(0.15)
                    context.stroke(bodyPath, with: .color(outlineColor), lineWidth: 1.5)
                    
                    // 3. Left Stubby Arm
                    var leftArm = Path()
                    leftArm.move(to: CGPoint(x: center.x - 24, y: center.y - 2))
                    leftArm.addQuadCurve(
                        to: CGPoint(x: center.x - 34, y: center.y + 4),
                        control: CGPoint(x: center.x - 32, y: center.y - 4)
                    )
                    leftArm.addQuadCurve(
                        to: CGPoint(x: center.x - 24, y: center.y + 10),
                        control: CGPoint(x: center.x - 30, y: center.y + 12)
                    )
                    context.fill(leftArm, with: .color(Color(red: 0.94, green: 0.96, blue: 1.0)))
                    
                    // 4. Right Stubby Arm
                    if state == .waving {
                        let waveAngle = sin(animationTime * 7.0) * 0.35
                        let armBase = CGPoint(x: center.x + 22, y: center.y - 4)
                        
                        cgContext.translateBy(x: armBase.x, y: armBase.y)
                        cgContext.rotate(by: waveAngle)
                        
                        var raisedArm = Path()
                        raisedArm.move(to: .zero)
                        raisedArm.addQuadCurve(
                            to: CGPoint(x: 14, y: -16),
                            control: CGPoint(x: 4, y: -14)
                        )
                        raisedArm.addQuadCurve(
                            to: CGPoint(x: 4, y: 4),
                            control: CGPoint(x: 16, y: -2)
                        )
                        raisedArm.closeSubpath()
                        
                        let armFill = Path(raisedArm.cgPath)
                        context.fill(armFill, with: .color(Color(red: 0.95, green: 0.96, blue: 1.0)))
                        
                        cgContext.rotate(by: -waveAngle)
                        cgContext.translateBy(x: -armBase.x, y: -armBase.y)
                    } else {
                        var rightArm = Path()
                        rightArm.move(to: CGPoint(x: center.x + 24, y: center.y - 2))
                        rightArm.addQuadCurve(
                            to: CGPoint(x: center.x + 34, y: center.y + 4),
                            control: CGPoint(x: center.x + 32, y: center.y - 4)
                        )
                        rightArm.addQuadCurve(
                            to: CGPoint(x: center.x + 24, y: center.y + 10),
                            control: CGPoint(x: center.x + 30, y: center.y + 12)
                        )
                        context.fill(rightArm, with: .color(Color(red: 0.94, green: 0.96, blue: 1.0)))
                    }
                    
                    // 5. Cute Blushing Cheeks
                    let cheekColor = Color(red: 1.0, green: 0.65, blue: 0.75).opacity(0.45)
                    let cheekShift = eyeOffsetX * 0.4
                    context.fill(
                        Path(ellipseIn: CGRect(x: center.x - 19 + cheekShift, y: center.y - 2, width: 8, height: 5)),
                        with: .color(cheekColor)
                    )
                    context.fill(
                        Path(ellipseIn: CGRect(x: center.x + 11 + cheekShift, y: center.y - 2, width: 8, height: 5)),
                        with: .color(cheekColor)
                    )
                    
                    // 6. Eyes & Mouth Expression
                    if state.isSleeping {
                        let eyeY = center.y - 12
                        var leftEye = Path()
                        leftEye.addArc(
                            center: CGPoint(x: center.x - 11, y: eyeY),
                            radius: 4,
                            startAngle: .degrees(0),
                            endAngle: .degrees(180),
                            clockwise: false
                        )
                        context.stroke(leftEye, with: .color(Color(white: 0.15)), lineWidth: 2.2)
                        
                        var rightEye = Path()
                        rightEye.addArc(
                            center: CGPoint(x: center.x + 11, y: eyeY),
                            radius: 4,
                            startAngle: .degrees(0),
                            endAngle: .degrees(180),
                            clockwise: false
                        )
                        context.stroke(rightEye, with: .color(Color(white: 0.15)), lineWidth: 2.2)
                    } else if state.isStartled {
                        // Item 5: Wide surprised eyes (O o O) and open gasp mouth
                        let eyeY = center.y - 14
                        let leftEyeRect = CGRect(x: center.x - 15, y: eyeY - 8, width: 10, height: 14)
                        let rightEyeRect = CGRect(x: center.x + 5, y: eyeY - 8, width: 10, height: 14)
                        
                        context.fill(Path(ellipseIn: leftEyeRect), with: .color(Color(white: 0.12)))
                        context.fill(Path(ellipseIn: rightEyeRect), with: .color(Color(white: 0.12)))
                        
                        let leftShine = CGRect(x: leftEyeRect.minX + 2, y: leftEyeRect.minY + 2.5, width: 3.5, height: 4.5)
                        let rightShine = CGRect(x: rightEyeRect.minX + 2, y: rightEyeRect.minY + 2.5, width: 3.5, height: 4.5)
                        context.fill(Path(ellipseIn: leftShine), with: .color(.white))
                        context.fill(Path(ellipseIn: rightShine), with: .color(.white))
                        
                        // Wide open gasp mouth
                        let gaspMouth = CGRect(x: center.x - 4, y: center.y + 4, width: 8, height: 10)
                        context.fill(Path(ellipseIn: gaspMouth), with: .color(Color(white: 0.15)))
                    } else {
                        let eyeY = center.y - 14
                        let currentEyeX = eyeOffsetX
                        
                        let leftEyeRect = CGRect(x: center.x - 14 + currentEyeX, y: eyeY - 6, width: 7, height: 11)
                        let rightEyeRect = CGRect(x: center.x + 7 + currentEyeX, y: eyeY - 6, width: 7, height: 11)
                        
                        context.fill(Path(ellipseIn: leftEyeRect), with: .color(Color(white: 0.12)))
                        context.fill(Path(ellipseIn: rightEyeRect), with: .color(Color(white: 0.12)))
                        
                        let leftShine = CGRect(x: leftEyeRect.minX + 1.5, y: leftEyeRect.minY + 2.0, width: 2.5, height: 3.5)
                        let rightShine = CGRect(x: rightEyeRect.minX + 1.5, y: rightEyeRect.minY + 2.0, width: 2.5, height: 3.5)
                        context.fill(Path(ellipseIn: leftShine), with: .color(.white))
                        context.fill(Path(ellipseIn: rightShine), with: .color(.white))
                    }
                }
            }
            .frame(width: 80, height: 85)
            .scaleEffect(x: facingDirection == .left ? -1 : 1, y: 1)
            
            if let emoji = currentEmoji {
                ThoughtBubbleView(emoji: emoji)
                    .offset(y: -52)
            }
            
            if state.isSleeping {
                SleepingZParticlesView(animationTime: animationTime)
                    .offset(y: -40)
            }
            
            if state.isFlipping {
                SparklesView(animationTime: animationTime)
            }
        }
    }
}

/// Item 4: Floating Will-o'-the-wisp flame particles in night mode
struct WillOWispParticlesView: View {
    let animationTime: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                let delay = Double(index) * 0.9
                let progress = (animationTime + delay).truncatingRemainder(dividingBy: 3.0) / 3.0
                let yOffset = -progress * 42.0
                let xOffset = sin(progress * .pi * 2.0 + Double(index)) * 22.0
                let opacity = (1.0 - progress) * 0.7
                
                Circle()
                    .fill(Color(red: 0.4, green: 0.85, blue: 1.0))
                    .frame(width: 6, height: 6)
                    .blur(radius: 2)
                    .shadow(color: Color.blue, radius: 4)
                    .offset(x: xOffset, y: yOffset)
                    .opacity(opacity)
            }
        }
    }
}

/// Item 3: Floating Thought Bubble View with Emoji
struct ThoughtBubbleView: View {
    let emoji: String
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
                    .frame(width: 38, height: 32)
                
                Text(emoji)
                    .font(.system(size: 18))
            }
            
            HStack(spacing: 3) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .shadow(color: Color.black.opacity(0.1), radius: 1)
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
                    .shadow(color: Color.black.opacity(0.1), radius: 1)
            }
            .offset(y: -2)
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: emoji)
    }
}

/// Floating animated 'z Z Z' particles drifting upward and fading.
struct SleepingZParticlesView: View {
    let animationTime: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                let delay = Double(index) * 1.1
                let cycleTime = (animationTime + delay).truncatingRemainder(dividingBy: 3.3)
                let progress = cycleTime / 3.3
                
                let yOffset = -progress * 38.0
                let xOffset = sin(progress * .pi * 3.0) * 8.0 + Double(index * 6 - 6)
                let opacity = progress < 0.2 ? (progress / 0.2) : (1.0 - (progress - 0.2) / 0.8)
                let scale = 0.7 + (progress * 0.5) + Double(index) * 0.15
                
                Text(index == 0 ? "z" : (index == 1 ? "Z" : "Z"))
                    .font(.system(size: 14 + CGFloat(index * 3), weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(opacity * 0.9))
                    .shadow(color: Color.blue.opacity(0.5), radius: 3)
                    .scaleEffect(scale)
                    .offset(x: xOffset, y: yOffset)
            }
        }
    }
}

/// Burst of floating sparkles when doing acrobatics!
struct SparklesView: View {
    let animationTime: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                let angle = Double(index) * (.pi / 3.0) + animationTime * 4.0
                let radius: CGFloat = 34.0
                let x = cos(angle) * radius
                let y = sin(angle) * radius
                
                Text("✨")
                    .font(.system(size: 14))
                    .offset(x: x, y: y)
                    .opacity(0.85)
            }
        }
    }
}
