{ config, lib, ... }:

{
  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = "lain@lainmail.xyz";
    group = lib.mkDefault "nginx";
    dnsProvider = "cloudflare";
    credentialFiles = {
      "CLOUDFLARE_DNS_API_TOKEN_FILE" = "/etc/somesecrets/cloudflare-api-token";
    };
  };
}