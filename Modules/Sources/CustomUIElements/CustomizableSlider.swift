//
//  CustomizableSlider.swift
//  BookSummaryPlayerTestTask
//
//  Created by Yulian on 23.01.2024.
//

import SwiftUI

import Utils

public struct CustomizableSlider: UIViewRepresentable {
    
    public final class Coordinator: NSObject {
        var value: Binding<Double>
        
        public init(value: Binding<Double>) {
            self.value = value
        }
        
        @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Double(sender.value)
        }
    }
    
    var thumbColor: UIColor = .blue
    var thumbSize: CGFloat = 15.0
    var minTrackColor: UIColor?
    var maxTrackColor: UIColor?
    
    @Binding var value: Double
    var maxValue: Double
    
    public func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        
        setThumbImage(forSlider: slider)
        
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        slider.maximumValue = Float(maxValue)
        slider.value = Float(value)
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        
        // Thumb image does not update without this
        slider.registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (slider: UISlider, previousTraitCollection: UITraitCollection) in
            setThumbImage(forSlider: slider)
        }
        
        return slider
    }
    
    public func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.maximumValue = Float(self.maxValue)
        uiView.value = Float(self.value)
    }
    
    public func makeCoordinator() -> CustomizableSlider.Coordinator {
        Coordinator(value: $value)
    }
    
    private func setThumbImage(forSlider slider: UISlider) {
        let configuration = UIImage.SymbolConfiguration(pointSize: thumbSize)
       
        let image = UIImage(systemName: "circle.fill", withConfiguration: configuration)?.withColor(thumbColor)

        slider.setThumbImage(image, for: .normal)
    }
    
    public init(value: Binding<Double>, maxValue: Double, thumbColor: UIColor = .blue, thumbSize: CGFloat = 15.0, minTrackColor: UIColor? = nil, maxTrackColor: UIColor? = nil) {
        self._value = value
        self.maxValue = maxValue
        self.thumbColor = thumbColor
        self.thumbSize = thumbSize
        self.minTrackColor = minTrackColor
        self.maxTrackColor = maxTrackColor
    }
}

#if DEBUG
struct CustomizableSlider_Previews: PreviewProvider {
    static var previews: some View {
        CustomizableSlider(
            value: .constant(0.5), maxValue: 100, thumbColor: .blue,
            minTrackColor: .blue,
            maxTrackColor: .green
        )
    }
}
#endif
