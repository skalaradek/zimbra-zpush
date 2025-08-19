#!/bin/bash

TEMPLATE="/opt/zimbra/conf/nginx/templates/nginx.conf.web.https.default.template"
BACKUP="${TEMPLATE}.bak.$(date +%F-%H%M%S)"
DRY_RUN=false
FIX_TYPE="both"

# Check for dry-run flag
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "🔍 Dry-run mode enabled. No changes will be written."
fi

# Prompt for fix type
read -p "Apply fix for [autodiscover], [activesync], or [both] (default)? " input
if [[ "$input" =~ ^(autodiscover|activesync|both)$ ]]; then
  FIX_TYPE="$input"
fi

echo -e "\n🔧 Selected fix: $FIX_TYPE"

# Show preview
echo -e "\n📄 Preview of changes:\n"

if [[ "$FIX_TYPE" == "autodiscover" || "$FIX_TYPE" == "both" ]]; then
  echo "🛠️  Will modify /autodiscover block:"
  grep -A 20 "location \^~ /autodiscover" "$TEMPLATE" | head -n 25
fi

if [[ "$FIX_TYPE" == "activesync" || "$FIX_TYPE" == "both" ]]; then
  echo -e "\n🛠️  Will inject Z-Push block into /Microsoft-Server-ActiveSync:"
  grep -A 20 "location \^~ /Microsoft-Server-ActiveSync" "$TEMPLATE" | head -n 25
fi

# Apply changes
if ! $DRY_RUN; then
  cp "$TEMPLATE" "$BACKUP"
  echo -e "\n📦 Backup saved as: $BACKUP"

  if [[ "$FIX_TYPE" == "autodiscover" || "$FIX_TYPE" == "both" ]]; then
    sed -i '/location \^~ \/autodiscover/,/proxy_redirect http:\/\/\$relhost\/ https:\/\/\$http_host\// {
      s|location \^~ /autodiscover|location ~* /autodiscover|;
      /# Proxy to Zimbra Mailbox Upstream/d;
      /proxy_pass[[:space:]]\+\$autodiscover_upstream;/d;
      /# End stray redirect hack/a\
        \n        # Z-Push start\n        include /opt/z-push/nginx-zpush-autodiscover.conf;\n        # Z-Push end\n
    }' "$TEMPLATE"
  fi

  if [[ "$FIX_TYPE" == "activesync" || "$FIX_TYPE" == "both" ]]; then
    sed -i '/location \^~ \/Microsoft-Server-ActiveSync/,/proxy_buffering[[:space:]]\+off;/ {
      /proxy_buffering[[:space:]]\+off;/a\
        \n        # Z-Push start\n        include /opt/z-push/nginx-zpush.conf;\n        # Z-Push end\n
    }' "$TEMPLATE"
  fi

  echo -e "\n✅ Changes applied successfully."
else
  echo -e "\n🚫 Dry-run complete. No changes written."
fi

