tailscale_ip=$(tailscale ip -4)
if [[ $tailscale_ip != "" ]]; then
  export IP=$tailscale_ip
fi
unset tailscale_ip
