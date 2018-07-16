@objc public class ExploreFeedPreferencesUpdateCoordinator: NSObject {
    private let feedContentController: WMFExploreFeedContentController
    private var oldExploreFeedPreferences = Dictionary<String, Any>()
    private var newExploreFeedPreferences = Dictionary<String, Any>()
    private var willTurnOnContentGroupOrLanguage = false

    @objc public init(feedContentController: WMFExploreFeedContentController) {
        self.feedContentController = feedContentController
    }

    @objc public func configure(oldExploreFeedPreferences: Dictionary<String, Any>, newExploreFeedPreferences: Dictionary<String, Any>, willTurnOnContentGroupOrLanguage: Bool) {
        self.oldExploreFeedPreferences = oldExploreFeedPreferences
        self.newExploreFeedPreferences = newExploreFeedPreferences
        self.willTurnOnContentGroupOrLanguage = willTurnOnContentGroupOrLanguage
    }

    @objc public func coordinateUpdate(from viewController: UIViewController) {
        if willTurnOnContentGroupOrLanguage {
            guard UserDefaults.wmf_userDefaults().defaultTabType == .settings else {
                feedContentController.saveNewExploreFeedPreferences(newExploreFeedPreferences, updateFeed: true)
                return
            }
            guard areAllLanguagesTurnedOff(in: oldExploreFeedPreferences) else {
                feedContentController.saveNewExploreFeedPreferences(newExploreFeedPreferences, updateFeed: true)
                return
            }
            guard areGlobalCardsTurnedOff(in: oldExploreFeedPreferences) else {
                feedContentController.saveNewExploreFeedPreferences(newExploreFeedPreferences, updateFeed: true)
                return
            }
            // TODO
        } else {
            guard UserDefaults.wmf_userDefaults().defaultTabType == .explore else {
                feedContentController.saveNewExploreFeedPreferences(newExploreFeedPreferences, updateFeed: true)
                return
            }
            guard areAllLanguagesTurnedOff(in: newExploreFeedPreferences) else {
                feedContentController.saveNewExploreFeedPreferences(newExploreFeedPreferences, updateFeed: true)
                return
            }
            guard areGlobalCardsTurnedOff(in: newExploreFeedPreferences) else {
                feedContentController.saveNewExploreFeedPreferences(newExploreFeedPreferences, updateFeed: true)
                return
            }
            let alertController = UIAlertController(title: WMFLocalizedString("explore-feed-preferences-turn-off-explore-feed-alert-title", value: "Turn off Explore feed?", comment: "Title for alert that allows user to decide whether they want to turn off Explore feed"), message: WMFLocalizedString("explore-feed-preferences-turn-off-explore-feed-alert-message", value: "Hiding all Explore feed cards will turn off the Explore tab and replace it with a Settings tab", comment: "Message for alert that allows user to decide whether they want to turn off Explore feed"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: WMFLocalizedString("explore-feed-preferences-turn-off-explore-feed-alert-action-title", value: "Turn off Explore feed", comment: "Title for action alert that allows user to turn off Explore feed"), style: .destructive, handler: { (_) in
                UserDefaults.wmf_userDefaults().defaultTabType = .settings
                self.feedContentController.saveNewExploreFeedPreferences(self.newExploreFeedPreferences, updateFeed: true)
            }))
            alertController.addAction(UIAlertAction(title: CommonStrings.cancelActionTitle, style: .cancel, handler: { (_) in
                self.feedContentController.rejectNewExploreFeedPreferences()
            }))
            present(alertController, from: viewController)
        }
    }

    private func present(_ alertController: UIAlertController, from presenter: UIViewController) {
        if let presenter = presenter.presentedViewController {
            if presenter is UINavigationController {
                presenter.present(alertController, animated: true)
            }
        } else {
            presenter.present(alertController, animated: true)
        }
    }

    private func areAllLanguagesTurnedOff(in exploreFeedPreferences: Dictionary<String, Any>) -> Bool {
        guard exploreFeedPreferences.count == 1 else {
            return false
        }
        guard exploreFeedPreferences.first?.key == WMFExploreFeedPreferencesGlobalCardsKey else {
            assertionFailure("Expected value with key WMFExploreFeedPreferencesGlobalCardsKey")
            return false
        }
        return true
    }

    private func globalCardPreferences(in exploreFeedPreferences: Dictionary<String, Any>) -> Dictionary<NSNumber, NSNumber>? {
        guard let globalCardPreferences = exploreFeedPreferences[WMFExploreFeedPreferencesGlobalCardsKey] as? Dictionary<NSNumber, NSNumber> else {
            assertionFailure("Expected value of type Dictionary<NSNumber, NSNumber>")
            return nil
        }
        return globalCardPreferences
    }

    private func areGlobalCardsTurnedOff(in exploreFeedPreferences: Dictionary<String, Any>) -> Bool {
        guard let globalCardPreferences = globalCardPreferences(in: exploreFeedPreferences) else {
            return false
        }
        return globalCardPreferences.values.filter { $0.boolValue == true }.isEmpty
    }
}
