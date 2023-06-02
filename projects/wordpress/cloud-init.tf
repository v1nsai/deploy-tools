variable "mysql_root_password" { type = string }
variable "mysql_wp_user_password" { type = string }
variable "wordpress_username" { type = string }
variable "wordpress_password" { type = string }
variable "lemp_install_script" { type = string }

data "template_cloudinit_config" "cloud-config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "packages"
    content_type = "text/cloud-config"
    content      = <<-EOF
      package_update: true
      packages:
        - easy-rsa
        - openssl
        - net-tools
        - unzip
        - nginx
        - mariadb-server
        - php-fpm
        - php-mysql
        - php-curl
        - php-gd
        - php-intl
        - php-mbstring
        - php-soap
        - php-xml
        - php-xmlrpc
        - php-zip
      EOF
  }

  part {
    filename     = "users"
    content_type = "text/cloud-config"
    content      = <<-EOF
      users:
        - name: drew
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          groups: [sudo, www-data]
          shell: /bin/bash
          lock_passwd: false
          passwd: $6$rounds=4096$nQEeaHtrjiUlxOPi$LQlgi0XBR6u46AJFhWxsWBBK8YqHbGWYWkWnG.YhmdYkc/lMiAacMwQAbZ0W7MosLFexushHQpfa05eG7gsL/1
          ssh-authorized-keys:
            - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCX3ZnnojSpqi1R7CWmP7uVFU2fEd2uS4PYQpWC23ScmDGP7KFHeTJfMc6eMaAhbxfIXx2CFdsIhP5U58BFLmAxkUIM8lGnHgh1uME/aOMZokZrDhYnw0eaamVOg0rdKD/uaTo87ASoxpf0XYnrqcrYhFIQodxjsCC8pCU5Egjh9QDgHsniJ5vWEkxZGPQ4SXIj4txh8uXMI0mh57BWJRK0zJIDzZCxubtrOpWoQnVvg/ZV+Thgy0P9m7e8OHbaM3U/7p4DBd1MZ95jNwjefMeD5hR46T35rkR9w/ebEIKhGjz0UB2yRUZPOPqBzVfixYA6gfd5c1AhjluCyCqhLEMd Generated-by-Nova
        - name: wordpress
          sudo: false
          groups: [www-data]
          shell: /bin/bash
          lock_passwd: false
      EOF
  }

  part {
    filename     = "write_files"
    content_type = "text/cloud-config"
    content      = <<-EOF
      write_files:
        - path: /tmp/generate-certs.sh
          permissions: "700"
          owner: root
          content: |
            ${file("../../scripts/generate-certs.sh")}
        - path: /etc/environment
          permissions: "0644"
          owner: root
          append: true
          content: |
            MYSQL_ROOT_PASSWORD=${var.mysql_root_password}
            MYSQL_WP_USER_PASSWORD=${var.mysql_wp_user_password}
            WORDPRESS_USERNAME=${var.wordpress_username}
            WORDPRESS_PASSWORD=${var.wordpress_password}
        - path: /etc/ssh/sshd_config
          content: |
            Port 1355
            PermitRootLogin no
            PasswordAuthentication yes
          append: true
        - path: /tmp/lemp-install.sh
          encoding: base64
          permissions: "700"
          content: |
            IyEvYmluL2Jhc2gKCnNldCAtZQoKIyBTZXQgYm90aCBvZiB0aGVzZSB0byBjdXN0b20gZG9tYWluIG9yIGluZGljYXRlZCBkZWZhdWx0cwojIGRlZmF1bHQgbm9uZQpET01BSU5fT1JfTk9ORT0KIyBkZWZhdWx0ICJkZWZhdWx0IgpET01BSU5fT1JfREVGQVVMVD0iZGVmYXVsdCIKCiMgSW5zdGFsbCBwYWNrYWdlcwphcHQgdXBkYXRlIHx8IHRydWUKYXB0IGluc3RhbGwgLXkgbmdpbnggbWFyaWFkYi1zZXJ2ZXIgcGhwLWZwbSBwaHAtbXlzcWwgcGhwLWN1cmwgcGhwLWdkIHBocC1pbnRsIHBocC1tYnN0cmluZyBwaHAtc29hcCBwaHAteG1sIHBocC14bWxycGMgcGhwLXppcAoKIyBDb25maWd1cmUgbWFyaWFkYgpzeXN0ZW1jdGwgc3RvcCBteXNxbApraWxsYWxsIC05IG15c3FsZF9zYWZlIG15c3FsZCBtYXJpYWRiIG1hcmlhZGJkIG15c3FsIHx8IHRydWUKZWNobyAiRGlzYWJsaW5nIGdyYW50IHRhYmxlcyBhbmQgbmV0d29ya2luZyIKbXlzcWxkX3NhZmUgLS1za2lwLWdyYW50LXRhYmxlcyAtLXNraXAtbmV0d29ya2luZyAmPi9kZXYvbnVsbCAmIGRpc293bgplY2hvICJXYWl0aW5nIGZvciBteXNxbCB0byBzdGFydCIKc2xlZXAgMTAKbXlzcWwgLXVyb290IC1lICJGTFVTSCBQUklWSUxFR0VTOyBBTFRFUiBVU0VSICdyb290J0AnbG9jYWxob3N0JyBJREVOVElGSUVEIEJZICckTVlTUUxfUk9PVF9QQVNTV09SRCc7ICIKa2lsbGFsbCAtOSBteXNxbGRfc2FmZSBtYXJpYWRiZCB8fCB0cnVlCmVjaG8gIlJlc3RhcnRpbmcgbXlzcWwiCnN5c3RlbWN0bCBzdGFydCBteXNxbAoKbXlzcWwgLS11c2VyPXJvb3QgLS1wYXNzd29yZD0ke01ZU1FMX1JPT1RfUEFTU1dPUkR9IC1lICIKREVMRVRFIEZST00gbXlzcWwudXNlciBXSEVSRSBVc2VyPSdyb290JyBBTkQgSG9zdCBOT1QgSU4gKCdsb2NhbGhvc3QnLCAnMTI3LjAuMC4xJywgJzo6MScpOwpERUxFVEUgRlJPTSBteXNxbC51c2VyIFdIRVJFIFVzZXI9Jyc7CkRFTEVURSBGUk9NIG15c3FsLmRiIFdIRVJFIERiPSd0ZXN0JyBPUiBEYj0ndGVzdF8lJzsKQ1JFQVRFIFVTRVIgJ3dvcmRwcmVzc3VzZXInQCdsb2NhbGhvc3QnIElERU5USUZJRUQgQlkgJyR7TVlTUUxfV1BfVVNFUl9QQVNTV09SRH0nOwpDUkVBVEUgREFUQUJBU0Ugd29yZHByZXNzIERFRkFVTFQgQ0hBUkFDVEVSIFNFVCB1dGY4IENPTExBVEUgdXRmOF91bmljb2RlX2NpOwpHUkFOVCBBTEwgT04gd29yZHByZXNzLiogVE8gJ3dvcmRwcmVzc3VzZXInQCdsb2NhbGhvc3QnOwpGTFVTSCBQUklWSUxFR0VTOyAiCgojIENvbmZpZ3VyZSBwaHAKc3lzdGVtY3RsIHJlc3RhcnQgcGhwNy40LWZwbQoKIyBDb25maWd1cmUgbmdpbngKbWtkaXIgLXAgL3Zhci93d3cvJERPTUFJTl9PUl9OT05FIApjaG93biAtUiB3b3JkcHJlc3M6d29yZHByZXNzIC92YXIvd3d3LyRET01BSU5fT1JfTk9ORQp0b3VjaCAvZXRjL25naW54L3NpdGVzLWF2YWlsYWJsZS8kRE9NQUlOX09SX0RFRkFVTFQKZWNobyAiIyBnZW5lcmF0ZWQgMjAyMy0wNS0yOSwgTW96aWxsYSBHdWlkZWxpbmUgdjUuNywgbmdpbnggMS4xNy43LCBPcGVuU1NMIDEuMS4xaywgaW50ZXJtZWRpYXRlIGNvbmZpZ3VyYXRpb24KIyBodHRwczovL3NzbC1jb25maWcubW96aWxsYS5vcmcvI3NlcnZlcj1uZ2lueCZ2ZXJzaW9uPTEuMTcuNyZjb25maWc9aW50ZXJtZWRpYXRlJm9wZW5zc2w9MS4xLjFrJmd1aWRlbGluZT01LjcKc2VydmVyIHsKICAgIGxpc3RlbiA4MDsKICAgIGxpc3RlbiBbOjpdOjgwOwoKICAgIHJvb3QgL3Zhci93d3cvJERPTUFJTl9PUl9OT05FOwogICAgaW5kZXggaW5kZXgucGhwIGluZGV4Lmh0bWwgaW5kZXguaHRtOwoKICAgIHNlcnZlcl9uYW1lICRET01BSU5fT1JfREVGQVVMVDsKCiAgICBsb2NhdGlvbiAvIHsKICAgICAgICAjIHRyeV9maWxlcyAkdXJpICR1cmkvID00MDQ7CiAgICAgICAgdHJ5X2ZpbGVzICR1cmkgJHVyaS8gL2luZGV4LnBocCRpc19hcmdzJGFyZ3M7CiAgICB9CgogICAgbG9jYXRpb24gfiBcLnBocCQgewogICAgICAgIGluY2x1ZGUgc25pcHBldHMvZmFzdGNnaS1waHAuY29uZjsKICAgICAgICBmYXN0Y2dpX3Bhc3MgdW5peDovdmFyL3J1bi9waHAvcGhwNy40LWZwbS5zb2NrOwogICAgfQoKICAgICMgRGlnaXRhbG9jZWFuIHdvcmRwcmVzcwogICAgbG9jYXRpb24gPSAvZmF2aWNvbi5pY28geyBsb2dfbm90X2ZvdW5kIG9mZjsgYWNjZXNzX2xvZyBvZmY7IH0KICAgIGxvY2F0aW9uID0gL3JvYm90cy50eHQgeyBsb2dfbm90X2ZvdW5kIG9mZjsgYWNjZXNzX2xvZyBvZmY7IGFsbG93IGFsbDsgfQogICAgbG9jYXRpb24gfiogXC4oY3NzfGdpZnxpY298anBlZ3xqcGd8anN8cG5nKSQgewogICAgICAgIGV4cGlyZXMgbWF4OwogICAgICAgIGxvZ19ub3RfZm91bmQgb2ZmOwogICAgfQp9CgpzZXJ2ZXIgewogICAgbGlzdGVuIDQ0MyBzc2wgaHR0cDI7CiAgICBsaXN0ZW4gWzo6XTo0NDMgc3NsIGh0dHAyOwoKICAgIHNzbF9jZXJ0aWZpY2F0ZSAvZXRjL3NzbC9wcml2YXRlL3NlcnZlci5jcnQ7CiAgICBzc2xfY2VydGlmaWNhdGVfa2V5IC9ldGMvc3NsL3ByaXZhdGUvc2VydmVyLmtleTsKICAgIHNzbF9zZXNzaW9uX3RpbWVvdXQgMWQ7CiAgICBzc2xfc2Vzc2lvbl9jYWNoZSBzaGFyZWQ6TW96U1NMOjEwbTsgICMgYWJvdXQgNDAwMDAgc2Vzc2lvbnMKICAgIHNzbF9zZXNzaW9uX3RpY2tldHMgb2ZmOwoKICAgICMgY3VybCBodHRwczovL3NzbC1jb25maWcubW96aWxsYS5vcmcvZmZkaGUyMDQ4LnR4dCA+IC9wYXRoL3RvL2RocGFyYW0KICAgIHNzbF9kaHBhcmFtIC9wYXRoL3RvL2RocGFyYW07CgogICAgIyBpbnRlcm1lZGlhdGUgY29uZmlndXJhdGlvbgogICAgc3NsX3Byb3RvY29scyBUTFN2MS4yIFRMU3YxLjM7CiAgICBzc2xfY2lwaGVycyBFQ0RIRS1FQ0RTQS1BRVMxMjgtR0NNLVNIQTI1NjpFQ0RIRS1SU0EtQUVTMTI4LUdDTS1TSEEyNTY6RUNESEUtRUNEU0EtQUVTMjU2LUdDTS1TSEEzODQ6RUNESEUtUlNBLUFFUzI1Ni1HQ00tU0hBMzg0OkVDREhFLUVDRFNBLUNIQUNIQTIwLVBPTFkxMzA1OkVDREhFLVJTQS1DSEFDSEEyMC1QT0xZMTMwNTpESEUtUlNBLUFFUzEyOC1HQ00tU0hBMjU2OkRIRS1SU0EtQUVTMjU2LUdDTS1TSEEzODQ6REhFLVJTQS1DSEFDSEEyMC1QT0xZMTMwNTsKICAgIHNzbF9wcmVmZXJfc2VydmVyX2NpcGhlcnMgb2ZmOwoKICAgICMgSFNUUyAobmd4X2h0dHBfaGVhZGVyc19tb2R1bGUgaXMgcmVxdWlyZWQpICg2MzA3MjAwMCBzZWNvbmRzKQogICAgYWRkX2hlYWRlciBTdHJpY3QtVHJhbnNwb3J0LVNlY3VyaXR5ICJtYXgtYWdlPTYzMDcyMDAwIiBhbHdheXM7CgogICAgIyBPQ1NQIHN0YXBsaW5nCiAgICBzc2xfc3RhcGxpbmcgb247CiAgICBzc2xfc3RhcGxpbmdfdmVyaWZ5IG9uOwoKICAgICMgdmVyaWZ5IGNoYWluIG9mIHRydXN0IG9mIE9DU1AgcmVzcG9uc2UgdXNpbmcgUm9vdCBDQSBhbmQgSW50ZXJtZWRpYXRlIGNlcnRzCiAgICBzc2xfdHJ1c3RlZF9jZXJ0aWZpY2F0ZSAvZXRjL3NzbC9jZXJ0cy9jYS1idW5kbGUucGVtOwoKICAgICMgcmVwbGFjZSB3aXRoIHRoZSBJUCBhZGRyZXNzIG9mIHlvdXIgcmVzb2x2ZXIKICAgIHJlc29sdmVyIDEyNy4wLjAuMTsKfQoiID4gL2V0Yy9uZ2lueC9zaXRlcy1hdmFpbGFibGUvJERPTUFJTl9PUl9ERUZBVUxUCmxuIC1zIC9ldGMvbmdpbngvc2l0ZXMtYXZhaWxhYmxlLyRET01BSU5fT1JfREVGQVVMVCAvZXRjL25naW54L3NpdGVzLWVuYWJsZWQvJERPTUFJTl9PUl9ERUZBVUxUIHx8IHRydWUKCiMgVXBkYXRlIGNlcnRzCi91c3Ivc2Jpbi91cGRhdGUtY2EtY2VydGlmaWNhdGVzCgpuZ2lueCAtdApzeXN0ZW1jdGwgcmVsb2FkIG5naW54CgojIEluc3RhbGwgd29yZHByZXNzCnJtIC1yZiAvdmFyL3d3dy9odG1sLyoKd2dldCAtUCAvdG1wLyBodHRwczovL3dvcmRwcmVzcy5vcmcvbGF0ZXN0LnppcAp1bnppcCAvdG1wL2xhdGVzdC56aXAgLWQgL3RtcAptdiAvdG1wL3dvcmRwcmVzcy8qIC92YXIvd3d3LyRET01BSU5fT1JfTk9ORQoKIyBGaXggZm9sZGVyIHBlcm1pc3Npb25zCmNobW9kIDc1NSAtUiAvdmFyL3d3dy8KY2hvd24gd3d3LWRhdGE6d3d3LWRhdGEgLVIgL3Zhci93d3cv
    EOF
  }

  part {
    filename     = "runcmd"
    content_type = "text/cloud-config"
    content      = <<-EOF
      runcmd:
        - cp /etc/skel/.bashrc /home/drew/.profile
        - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/drew/.profile
        - chown drew:drew /home/drew/.profile
        - systemctl restart ssh
        - /tmp/generate-certs.sh
        - /tmp/lemp-install.sh
      EOF
  }
}