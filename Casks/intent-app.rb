# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.3.2
#   commit    7282d3bfcc660c06910c8fd56d55e841bdb21113
cask "intent-app" do
  version "3.3.2"
  sha256 "44e50afe25f8f289d0f47f6d9b7ba5e7b0dd8ead8d6935b913160657b46e0eb4"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
