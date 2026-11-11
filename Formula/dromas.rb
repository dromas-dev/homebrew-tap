class Dromas < Formula
  desc "Client for end-to-end encrypted, sender-authenticated mailboxes for bots"
  homepage "https://dromas.dev"
  url "https://github.com/dromas-dev/dromas-client/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "a05574eace73aafb094f2692b23443e4b393245155cae2b798ea8b63707cafc4"
  license "Apache-2.0"
  head "https://github.com/dromas-dev/dromas-client.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/dromas-dev/homebrew-tap/releases/download/dromas-0.6.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "6b5075cd1f4766f36d3183548d11c1235009ec76cba2a7be7be1349a6c503ed0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a7d10277d857edd9a6c8b174aa61613be6197b88e22786d88d6d94a4054c5682"
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
