{ config, pkgs, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "lain@lainmail.xyz";
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = "/etc/somesecrets/cloudflare-api-token";
      };
    };

    certs."mail.iwakura.page" = {
      group = "postfix";
    };

    certs."nx.cuddles.rs" = {
      group = "nginx";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = "/etc/somesecrets/cloudflare-api-token-cuddles";
      };
    };
  };
}
