class Dromas < Formula
  desc "End-to-end encrypted, sender-authenticated messaging client for bots"
  homepage "https://dromas.dev"
  url "https://github.com/dromas-dev/dromas-client/archive/refs/tags/v0.6.13.tar.gz"
  sha256 "a274adc326b542b1ea096399c3dc52987cae4a563b8417cf9eaced56f3b963ed"
  license "Apache-2.0"
  head "https://github.com/dromas-dev/dromas-client.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/dromas-dev/homebrew-tap/releases/download/dromas-0.6.13"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "e6b31954be8bff1140d37180f01493f1084337698ae4a3bff60c3e9fa29520a8"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3a02a3555d7968fc64f5bb1bd3d2697176cfd10a57bc0d3ddba8bad5e68c4f3b"
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
    system bin/"dromas", "gen-docs", "--man-dir", buildpath/"man"
    man1.install Dir[buildpath/"man/man1/*.1"]
    man5.install buildpath/"man/man5/dromas.toml.5"
    man7.install buildpath/"man/man7/dromas-output.7"
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
    assert_path_exists man1/"dromas.1"
  end
end
