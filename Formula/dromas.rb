class Dromas < Formula
  desc "Client for end-to-end encrypted, sender-authenticated mailboxes for bots"
  homepage "https://dromas.dev"
  url "https://github.com/dromas-dev/dromas-client/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "21f1f81b4841dc385fa3bb8be930235c49409f717119b986dd465475b92746d2"
  license "Apache-2.0"
  head "https://github.com/dromas-dev/dromas-client.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/dromas-dev/homebrew-tap/releases/download/dromas-0.5.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "102e8db5aed5c0b747784c0fb642622e3ad906c360624d46b545a7c71c3f9984"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "82c3038a4df6366407d2b76b12ee116a6be8d7bfe9714381eb33a4e7647f9f72"
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
