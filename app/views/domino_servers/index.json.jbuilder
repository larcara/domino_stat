json.array!(@domino_servers) do |domino_server|
  json.extract! domino_server, :id, :name, :ip, :ldap_port, :ldap_ssl
  json.url domino_server_url(domino_server, format: :json)
end
