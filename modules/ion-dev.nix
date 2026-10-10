# temporary: used by toaster
{ ... }: {
  networking.firewall.allowedTCPPorts = [ 8080 3001 ];
}
