cask "intent-app" do
  version "3.2.7"
  sha256 "3825d202de9b7ba9aa0913ec6a488ecbd81fe9282ff50251e42bd7718d200ed7"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
