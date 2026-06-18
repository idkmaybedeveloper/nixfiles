{ lib, ... }:

{
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
      PrintMotd = true;
      Banner = lib.mkDefault "/etc/motd.ssh";
      KexAlgorithms = [
        "sntrup761x25519-sha512"
        "sntrup761x25519-sha512@openssh.com"
      ];
      Ciphers = [ "aes256-gcm@openssh.com" ];
      Macs = [
        "hmac-sha2-256-etm@openssh.com"
        "hmac-sha2-512-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
      # NOTE: these global-only directives must live in `settings`, not
      # `extraConfig` - the nixos module appends extraConfig after a Match block
      # where sshd rejects them (not allowed within a Match block)
      HostKeyAlgorithms = "rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512";
      RequiredRSASize = 3072;
      CASignatureAlgorithms = "sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256";
      HostbasedAcceptedAlgorithms = "sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-256";
      PubkeyAcceptedAlgorithms = "sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-256";
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
    extraConfig = ''
      AcceptEnv LANG LC_* COLORTERM NO_COLOR
    '';
    openFirewall = true;
  };
}
