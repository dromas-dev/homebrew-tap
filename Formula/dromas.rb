class Dromas < Formula
  desc "End-to-end encrypted, sender-authenticated messaging client for bots"
  homepage "https://dromas.dev"
  url "https://github.com/dromas-dev/dromas-client/archive/refs/tags/v0.6.3.tar.gz"
  sha256 "f08683ae3a48bae0bc8244f7bfb2239fd8cb9cf4befebab0d330397801a69add"
  license "Apache-2.0"
  head "https://github.com/dromas-dev/dromas-client.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/dromas-dev/homebrew-tap/releases/download/dromas-0.6.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "68c5e87e405b29964cbfb8eb877fa8adef262e40ffac94cdc27b44380fc24776"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "00b707a3576cfb770bdc00566fab813f982bfdd2b636a535e2f8f906404deb00"
  end

  depends_on "go" => :build

  def install
    # A release's source archive carries no VCS information, so the build
    # records no version: the release is given at link time instead, as the
    # client's LinkedVersion says. A HEAD build is a git checkout, which Go
    # stamps itself. CGO off, as the release binaries are built.
    ENV["CGO_ENABLED"] = "0"
    ldflags = %w[-s -w]
    ldflags << "-X github.com/dromas-dev/dromas-client/client.LinkedVersion=v#{version}" unless build.head?
    system "go", "build", *std_go_args(ldflags:), "./cmd/dromas"
  end

  # The resident recv of the default profile, as the user. With --headers its
  # log gets who wrote each message and when, and none of the text a sender
  # chose: inbox/ keeps every message, and the profile's [recv] exec names the
  # program that runs for each, which gets the whole message.
  service do
    run [opt_bin/"dromas", "recv", "--follow", "--headers"]
    keep_alive true
    log_path var/"log/dromas.log"
    error_log_path var/"log/dromas.log"
  end

  test do
    assert_match "\"version\":\"v#{version}\"", shell_output("#{bin}/dromas version")
  end
end
