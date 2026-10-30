cask "intent-app" do
  version "3.2.8"
  sha256 "fb6c57fa07fa1cf184e579fbc3a3fd92eadec9c6a7d42b3fa3117aceb80a8b9f"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
