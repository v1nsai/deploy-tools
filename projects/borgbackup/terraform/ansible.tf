// resource "null_resource" "ansible_config" {
//   depends_on = [openstack_compute_instance_v2.borgbackup, openstack_compute_floatingip_associate_v2.fip_1]

//   triggers = {
//     always_run = "${timestamp()}"
//   }

//   provisioner "local-exec" {
//     command = "echo '${local.inventory_file}' > /tmp/playbook.yaml && sleep 10"
//   }
// }

// resource "null_resource" "ansible_provisioner" {
//   depends_on = [null_resource.ansible_config]

//   triggers = {
//     always_run = "${timestamp()}"
//   }

//   provisioner "local-exec" {
//     command = "ansible-playbook /tmp/playbook.yaml --inventory '${openstack_compute_floatingip_associate_v2.fip_1.floating_ip},' --user=localadmin --private-key=${pathexpand("~/.ssh/borgbackup")}"
//   }
// }

// locals {
//   inventory_file = <<EOF
//     - hosts: ${openstack_compute_floatingip_associate_v2.fip_1.floating_ip}
//       become: yes
//       vars:
//         user: backup
//         group: backup
//         home: /home/backup
//         pool: "{{ home }}/repos"
//         auth_users:
//         - host: backupserver
//           key: "{{ lookup('file', 'borgbackup.pub') }}"
//       tasks:
//         - package: name=borgbackup state=present
//         - group: name="{{ group }}" state=present
//         - user: name="{{ user }}" shell=/bin/bash home="{{ home }}" createhome=yes group="{{ group }}" groups= state=present
//         - file: path="{{ home }}" owner="{{ user }}" group="{{ group }}" mode=0700 state=directory
//         - file: path="{{ home }}/.ssh" owner="{{ user }}" group="{{ group }}" mode=0700 state=directory
//         - file: path="{{ pool }}" owner="{{ user }}" group="{{ group }}" mode=0700 state=directory
//         - authorized_key:
//             user="{{ user }}"
//             key="{{ item.key }}"
//             key_options='command="cd {{ pool }}/{{ item.host }};borg serve --restrict-to-path {{ pool }}/{{ item.host }}",restrict'
//           with_items: "{{ auth_users }}"
//         - file: path="{{ home }}/.ssh/authorized_keys" owner="{{ user }}" group="{{ group }}" mode=0600 state=file
//         - file: path="{{ pool }}/{{ item.host }}" owner="{{ user }}" group="{{ group }}" mode=0700 state=directory
//           with_items: "{{ auth_users }}"
//   EOF
// }
