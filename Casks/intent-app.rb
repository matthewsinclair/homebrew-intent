# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.5.3
#   commit    8475de82526a42742342c2c0df670ac468a212da
cask "intent-app" do
  version "3.5.3"
  sha256 "ac46bd951f4cf67fc5fcb76c589d3f54c75a8cdf435613503a6f84ab00978d34"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
