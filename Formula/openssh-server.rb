class OpensshServer < Formula
  desc "SSH server service wrapper for Homebrew openssh"
  homepage "https://www.openssh.com/"

  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "1.0.0"

  depends_on "openssh"

  def install
    # Create a simple wrapper script
    (bin/"openssh-server").write <<~EOS
      #!/bin/bash
      exec #{Formula["openssh"].opt_sbin}/sshd -D "$@"
    EOS
    
    chmod 0755, bin/"openssh-server"
    
    # Create config directory (user can add their own sshd_config)
    (etc/"openssh-server").mkpath
  end

  service do
    run [opt_bin/"openssh-server", "-f", etc/"openssh-server/sshd_config"]
    keep_alive true
    log_path var/"log/openssh-server.log"
    error_log_path var/"log/openssh-server.log"
    working_dir HOMEBREW_PREFIX
  end

  def caveats
    <<~EOS
      To start the SSH server service:
        brew services start openssh-server

      To stop the SSH server service:
        brew services stop openssh-server

      To restart the SSH server service:
        brew services restart openssh-server

      Configuration file is located at:
        #{etc}/openssh-server/sshd_config

      You need to generate SSH host keys before starting the service:
        ssh-keygen -t rsa -f #{etc}/openssh-server/ssh_host_rsa_key -N ""
        ssh-keygen -t ecdsa -f #{etc}/openssh-server/ssh_host_ecdsa_key -N ""
        ssh-keygen -t ed25519 -f #{etc}/openssh-server/ssh_host_ed25519_key -N ""

      Set proper permissions:
        chmod 600 #{etc}/openssh-server/ssh_host_*_key
        chmod 644 #{etc}/openssh-server/ssh_host_*_key.pub
    EOS
  end

  test do
    # Test that the wrapper script exists and is executable
    assert_predicate bin/"openssh-server", :exist?
    assert_predicate bin/"openssh-server", :executable?

    # Test that config directory was created
    assert_predicate etc/"openssh-server", :exist?
    assert_predicate etc/"openssh-server/sshd_config", :exist?
  end
end
