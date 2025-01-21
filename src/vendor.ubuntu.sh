tailscale_ip=$(tailscale ip -4)
if [[ $tailscale_ip != "" ]]; then
  export IP=$tailscale_ip
fi
unset tailscale_ip

isd() {
  if ! command -v "uvx" >/dev/null 2>&1; then
    echo "uvx is not installed"
    echo "Run:"
    echo "  pipx install uv"
    return 1
  fi

  uvx --python=3.12 --from git+https://github.com/isd-project/isd isd
}
