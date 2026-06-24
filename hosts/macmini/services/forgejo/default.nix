{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.forgejo = {
    enable = true;
    stateDir = "/var/lib/forgejo";
    database = {
      type = "sqlite3";
    };
    lfs.enable = true;
    settings = {
      DEFAULT.APP_NAME = "nx";
      server = {
        DOMAIN = "nx.cuddles.rs";
        ROOT_URL = "https://nx.cuddles.rs/";
        HTTP_PORT = 3030;
        HTTP_ADDR = "127.0.0.1";
        SSH_DOMAIN = "nx.cuddles.rs";
        SSH_PORT = 22;
        DISABLE_SSH = false;
        START_SSH_SERVER = false;
        LANDING_PAGE = "explore";
      };
      service = {
        DISABLE_REGISTRATION = true;
        REQUIRE_SIGNIN_VIEW = true;
        REGISTER_EMAIL_CONFIRM = false;
        ENABLE_NOTIFY_MAIL = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = false;
        ENABLE_CAPTCHA = false;
        DEFAULT_KEEP_EMAIL_PRIVATE = true;
        DEFAULT_ALLOW_CREATE_ORGANIZATION = true;
        DEFAULT_ENABLE_TIMETRACKING = true;
        NO_REPLY_ADDRESS = "noreply.localhost";
        ENABLE_INTERNAL_SIGNIN = true;
      };
      repository = {
        ENABLE_PUSH_CREATE_USER = true;
        FORCE_PRIVATE = true;
        DEFAULT_PRIVATE = "private";
        DEFAULT_PUSH_CREATE_PRIVATE = true;
        DISABLE_STARS = true;
        DISABLE_DOWNLOAD_SOURCE_ARCHIVES = true;
      };
      session = {
        COOKIE_SECURE = true;
      };
      mailer = {
        ENABLED = false;
      };
      openid = {
        ENABLE_OPENID_SIGNIN = false;
        ENABLE_OPENID_SIGNUP = false;
      };
      actions = {
        ENABLED = false;
      };
      other = {
        SHOW_FOOTER_VERSION = false;
        SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
        SHOW_FOOTER_POWERED_BY = false;
        ENABLE_SITEMAP = false;
        ENABLE_FEED = false;
      };
    };
  };
}
