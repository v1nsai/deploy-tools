variable "hashed_passwd" { type = string }

locals {
  ssh_pubkey   = file(pathexpand("~/.ssh/bmo.pub"))

  cloud_config = <<EOF
#cloud-config
ssh_pwauth: true
users:
  - name: doctor_ew
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin, sudo
    shell: /bin/bash
    lock_passwd: false
    passwd: ${var.hashed_passwd}
    ssh_authorized_keys:
      - ${local.ssh_pubkey}
apt:
  preserve_sources_list: true
  sources:
    deluge.list:
      source: "ppa:deluge-team/stable"
package_update: true
packages:
  - python3
  - python3-pip
  - python3-virtualenv
  - net-tools
  - wireguard
  - deluged
  - deluge-web
  - deluge-console
runcmd:
  # fucking cli colors
  - cp /etc/skel/.bashrc /home/doctor_ew/.profile
  - sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/doctor_ew/.profile
  - chown doctor_ew:doctor_ew /home/doctor_ew/.profile
  # set up plex
  - wget https://downloads.plex.tv/plex-media-server-new/1.32.4.7195-7c8f9d3b6/debian/plexmediaserver_1.32.4.7195-7c8f9d3b6_amd64.deb
  - dpkg -i plex*.deb
  - rm plex*.deb
  # - systemctl enable --now plexmediaserver.service
  - echo "30 3    * * *   root    /usr/sbin/shutdown -h" | sudo crontab -
  - ip rule add from $(curl ifconfig.me) table 128
  # - ip route add table 128 to  dev ens5
  - ip route add table 128 default via $(ip route show default | awk '{printf "%s", $3}')
EOF
}
