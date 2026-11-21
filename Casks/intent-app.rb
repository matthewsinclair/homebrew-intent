# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.5.0
#   commit    940c9535acf764e088a680b47f24cbd3050e691d
cask "intent-app" do
  version "3.5.0"
  sha256 "fc6d42051efcfa605085ad578d132f4ebea8ff8c7420ab2051e2f0f3a2e36bf7"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
