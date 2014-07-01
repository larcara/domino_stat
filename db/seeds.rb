# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

DominoServer.create(name: "postaweb.camera.it", ip: "postaweb.camera.it", ldap_port: "389", ldap_ssl: true, ldap_username: "", ldap_pwd: "", ldap_treebase: "", ldap_hostname: "postaweb.camera.it",  ldap_filter: "", ssh_user: "dommsw01", ssh_pwd: "P3c0Ra", tail_status: "", enabled_tail: true, enabled_auth: true)
DominoServer.create(name: "postaweb2.camera.it", ip: "postaweb2.camera.it", ldap_port: "389", ldap_ssl: true, ldap_username: "", ldap_pwd: "", ldap_treebase: "", ldap_hostname: "postaweb2.camera.it",  ldap_filter: "", ssh_user: "dommsw02", ssh_pwd: "P3c0Ra", tail_status: "", enabled_tail: true, enabled_auth: true)
DominoServer.create(name: "posta01.intra.camera.it", ip: "posta01.intra.camera.it", ldap_port: "389", ldap_ssl: true, ldap_username: "", ldap_pwd: "", ldap_treebase: "", ldap_hostname: "posta01.intra.camera.it",  ldap_filter: "", ssh_user: "dommsp01", ssh_pwd: "notes", tail_status: "", enabled_tail: true, enabled_auth: true)