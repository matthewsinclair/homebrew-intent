# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.4.0
#   commit    461e39ba145d12ebf3b14cb64c9b6a2526a7e89b
cask "intent-app" do
  version "3.4.0"
  sha256 "aa71a6bc45bbfaf56da9702fb7a4f8861f40bb28f1d47e62e121a8281af528c9"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
