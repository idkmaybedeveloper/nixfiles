{ lib, pkgs, ... }:

let
  # ref: https://github.com/C24Be/AS_Network_List rkn/scanner as nets,
  # mixed v4 and v6 CIDRs, one per line
  listUrl = "https://github.com/C24Be/AS_Network_List/raw/main/blacklists/blacklist.txt";

  stateDir = "/var/lib/rkn-blacklist";
  listFile = "${stateDir}/blacklist.txt";

  updater = pkgs.writeShellApplication {
    name = "rkn-blacklist-update";
    runtimeInputs = with pkgs; [
      curl
      nftables
      gnugrep
      gnused
      jq
      coreutils
    ];
    text = ''
      set -euo pipefail

      mkdir -p ${stateDir}
      tmp="$(mktemp -d)"
      trap 'rm -rf "$tmp"' EXIT

      if curl -fsSL --retry 3 --retry-delay 5 --max-time 120 -o "$tmp/raw" ${listUrl}; then
        install -m 0644 "$tmp/raw" ${listFile}
      elif [ -f ${listFile} ]; then
        echo "download failed, reapplying the cached list" >&2
      else
        echo "download failed and no cached list to fall back to" >&2
        exit 1
      fi

      sed -e 's/#.*//' -e 's/[[:space:]]//g' ${listFile} > "$tmp/clean"
      grep -E '^[0-9]+(\.[0-9]+){3}/[0-9]+$' "$tmp/clean" | paste -sd, - > "$tmp/v4" || true
      grep -E '^[0-9a-fA-F:]+/[0-9]+$'      "$tmp/clean" | paste -sd, - > "$tmp/v6" || true

      {
        echo 'table inet rkn_blacklist { }'
        echo 'delete table inet rkn_blacklist'
        echo 'table inet rkn_blacklist {'
        echo '  set v4 { type ipv4_addr; flags interval; auto-merge;'
        [ -s "$tmp/v4" ] && echo "    elements = { $(cat "$tmp/v4") }" || true
        echo '  }'
        echo '  set v6 { type ipv6_addr; flags interval; auto-merge;'
        [ -s "$tmp/v6" ] && echo "    elements = { $(cat "$tmp/v6") }" || true
        echo '  }'
        echo '  chain prerouting {'
        echo '    type filter hook prerouting priority raw; policy accept;'
        echo '    ip  saddr @v4 limit rate 10/second log prefix "Blocked IP attempt: "'
        echo '    ip  saddr @v4 drop'
        echo '    ip6 saddr @v6 limit rate 10/second log prefix "Blocked IP attempt: "'
        echo '    ip6 saddr @v6 drop'
        echo '  }'
        echo '}'
      } > "$tmp/ruleset.nft"

      nft -f "$tmp/ruleset.nft"

      count() { nft -j list set inet rkn_blacklist "$1" | jq '[.nftables[].set.elem[]?] | length'; }
      echo "blacklist applied: $(count v4) v4 intervals, $(count v6) v6 intervals"
    '';
  };
in
{
  systemd.services.rkn-blacklist = {
    description = "rebuild the rkn blacklist nftables set";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    # the set lives in the kernel only, so it has to be reapplied every boot
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe updater;
    };
  };

  systemd.timers.rkn-blacklist = {
    description = "daily rkn blacklist refresh";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  # NOTE: hits land in the kernel log, ie `journalctl -k -g 'blocked IP attempt'`
  environment.systemPackages = [ updater ];
}
