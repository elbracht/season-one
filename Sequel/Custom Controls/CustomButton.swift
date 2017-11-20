import SwiftTheme
import UIKit

class CustomButton: UIButton {

    private var colors: ThemeColorPicker!
    private var highlightColors: ThemeColorPicker!
    private var image: String?

    /* Init */
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /* Set */
    func setTitle(_ title: String, font: UIFont) {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
    }

    func setImage(_ imageName: String) {
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
        self.setImage(image, for: .highlighted)
    }

    func setColors(colors: ThemeColorPicker, highlightColors: ThemeColorPicker) {
        self.colors = colors
        self.highlightColors = highlightColors
        updateColor(colors)
    }

    /* Update */
    private func updateColor(_ colors: ThemeColorPicker) {
        self.theme_setTitleColor(colors, forState: .normal)
        self.theme_setTitleColor(colors, forState: .highlighted)
        self.imageView?.theme_tintColor = colors
    }

    /* Animation */
    private func animateDefault() {
        UIView.animate(withDuration: 0.1) {
            self.updateColor(self.colors)
        }
    }

    private func animateHighlight() {
        UIView.animate(withDuration: 0.1) {
            self.updateColor(self.highlightColors)
        }
    }

    /* Events */
    @objc private func buttonTouchDown(sender: CustomButton!) {
        animateHighlight()
    }

    @objc private func buttonTouchUpInside(sender: CustomButton!) {
        animateDefault()
    }

    @objc private func buttonTouchUpOutside(sender: CustomButton!) {
        animateDefault()
    }
}