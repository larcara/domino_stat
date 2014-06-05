json.array!(@names_entries) do |names_entry|
  json.extract! names_entry, :id, :server_id, :cn, :lastname, :firstname, :mailserver, :email, :level0, :level1, :level2, :level3, :level4, :uid, :displayname, :status
  json.url names_entry_url(names_entry, format: :json)
end
