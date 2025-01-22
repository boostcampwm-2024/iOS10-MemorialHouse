extension String {
    public func localized() -> String {
        NSLocalizedString(self, comment: "")
    }
}
