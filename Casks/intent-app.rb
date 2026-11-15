# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.3.3
#   commit    83dce9b27ad55055cd801b2165d2f6098b56bbe7
cask "intent-app" do
  version "3.3.3"
  sha256 "22e0fa51daaf301caaa4a9504f9f3ecc5e37c862e662e50890c54c448130831d"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
