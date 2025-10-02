class OpensshServer < Formula
  desc "Homebrew-managed sshd LaunchDaemon"
  homepage "https://github.com/gabbar/homebrew-tap"
  
  # Dummy URL for a service-only formula (SHA256 of /dev/null)
  url "file:///dev/null"
  version "1.0.0"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  # **CRITICAL DEPENDENCY:** Ensures OpenSSH is installed before the service is configured.
  depends_on "openssh"

  # **Resource Definition:** The file we install to satisfy the "not empty" requirement.
  # This assumes 'sshd_config.example' is in the root of your tap directory.
  # resource "sshd_config_example" do
  #   # Use File.expand_path to ensure the URL points correctly to the file in your tap
  #   url "file://#{File.expand_path(__dir__)}/../openssh-server/sshd_config.example"
  #   
  #   # You MUST update this hash whenever you change sshd_config.example
  #   # This is a placeholder; run 'shasum -a 256 sshd_config.example' for the real one.
  #   sha256 "90f8ec5669cd34183b9b0fdf8b94f5efb4c3672876330f4aa76088c2b4ad17be" 
  # end

  # def install
  #   # **FIX FOR "Empty Installation":** Install the example config file to satisfy Homebrew.
  #   # The file goes into $HOMEBREW_PREFIX/etc/openssh-server/sshd_config.example
  #   (etc/"openssh-server").install resource("sshd_config_example").fetch
  # end

  # def install
  #   # *** FINAL ROBUST FIX ***
  #   # 1. Define the source path to the config file (relative to the Formula file)
  #   #    '..' moves up from the 'Formula' directory to the tap root.
  #   config_source = Pathname.new(__dir__).parent/"openssh-server/sshd_config.example"
  #   
  #   # 2. Install the file into the Cellar prefix. 
  #   #    This ensures the installation is marked as non-empty.
  #   #    The file will reside at: $HOMEBREW_CELLAR/openssh-server/1.0.0/sshd_config.example
  #   prefix.install config_source
  #   
  #   # Optional: If you still want it in etc, you can link it manually (but often unnecessary)
  #   # etc.install_symlink prefix/"sshd_config.example"
  # end


  def install
    # 1. Define the source path to the config file (same as before)
    config_source = Pathname.new(__dir__).parent/"openssh-server/sshd_config.example"
    
    # 2. *** FINAL FIX: Use share.install ***
    # This installs the file to: $HOMEBREW_PREFIX/share/openssh-server/sshd_config.example
    # This is the most reliable way to make the installation non-empty and avoid EPERM.
    (share/"openssh-server").install config_source
  end


  # **LaunchDaemon Plist Definition**
  # This is the configuration for 'sudo brew services start'
  # def plist
  ## plist not defined because we are using the service function
  # end

  # Optional but good practice for newer brew services management
  def service
    {
      :keep_alive => true,
      :run => [Formula["openssh"].opt_sbin/"sshd", "-D"],
      :environment_variables => { "PATH" => ENV["PATH"] },
      :log_path => "/var/log/homebrew.sshd.log",
      :error_log_path => "/var/log/homebrew.sshd.log",
      :require_root => true,
      :process_type => :background
    }
  end
end



