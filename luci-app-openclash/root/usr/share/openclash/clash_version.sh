#!/bin/bash

set_lock() {
   exec 884>"/tmp/lock/openclash_clash_version.lock" 2>/dev/null
   flock -x 884 2>/dev/null
}

del_lock() {
   flock -u 884 2>/dev/null
   rm -rf "/tmp/lock/openclash_clash_version.lock"
}

TIME=$(date "+%Y-%m-%d-%H")
CHTIME=$(date "+%Y-%m-%d-%H" -r "/tmp/clash_last_version" 2>/dev/null)
LAST_OPVER="/tmp/clash_last_version"
RELEASE_BRANCH=$(uci -q get openclash.config.release_branch || echo "master")
github_address_mod=$(uci -q get openclash.config.github_address_mod || echo 0)
if [ -n "$1" ]; then
   github_address_mod="$1"
fi
LOG_FILE="/tmp/openclash.log"
set_lock

if [ "$TIME" != "$CHTIME" ]; then
   if [ "$github_address_mod" != "0" ]; then
      if [ "$github_address_mod" == "https://cdn.jsdelivr.net/" ] || [ "$github_address_mod" == "https://fastly.jsdelivr.net/" ] || [ "$github_address_mod" == "https://testingcf.jsdelivr.net/" ]; then
         curl -SsL -m 60 "$github_address_mod"gh/vernesong/OpenClash@core/"$RELEASE_BRANCH"/core_version -o $LAST_OPVER 2>&1 
      elif [ "$github_address_mod" == "https://raw.fastgit.org/" ]; then
         curl -SsL -m 60 https://raw.fastgit.org/vernesong/OpenClash/core/"$RELEASE_BRANCH"/core_version -o $LAST_OPVER 2>&1 
      else
         curl -SsL -m 60 "$github_address_mod"https://raw.githubusercontent.com/vernesong/OpenClash/core/"$RELEASE_BRANCH"/core_version -o $LAST_OPVER 2>&1 
      fi
   else
      curl -SsL -m 60 https://raw.githubusercontent.com/vernesong/OpenClash/core/"$RELEASE_BRANCH"/core_version -o $LAST_OPVER 2>&1 
   fi
   
   if [ "${PIPESTATUS[0]}" -ne 0 ]; then
      rm -rf $LAST_OPVER
   fi
fi
del_lock
