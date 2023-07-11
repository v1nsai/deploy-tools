locals {
  ssh_security_group_id = "sg-01be6bcdc143cffc1"
  ubuntu_2204_ami_id    = "ami-053b0d53c279acc90"
  al2023_ami_id         = "ami-06ca3ca175f37dd66"
  subnet_id             = "subnet-0cce7cd1eb4c1f5dc"
}

resource "aws_instance" "bmo" {
  ami           = local.ubuntu_2204_ami_id
  instance_type = "t3.medium"
  security_groups = [ aws_security_group.plex.id, local.ssh_security_group_id ]
  user_data = local.cloud_config
  key_name  = "bmo"
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
  }

  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_size = 125
  }

  instance_market_options {
    market_type = "spot"
  }

  # network_interface {
  #   device_index         = 0
  #   network_interface_id = aws_network_interface.interface1.id
  # }

  # network_interface {
  #   device_index         = 1
  #   network_interface_id = aws_network_interface.interface2.id
  # }
}

# resource "aws_network_interface" "interface1" {
#   subnet_id       = local.subnet_id
#   security_groups = [aws_security_group.plex.id, local.ssh_security_group_id]
#   depends_on      = [aws_security_group.plex, aws_security_group.ssh]

#   # attachment {
#   #   instance     = aws_instance.bmo.id
#   #   device_index = 1
#   # }
# }

# resource "aws_network_interface" "interface2" {
#   subnet_id       = local.subnet_id
#   security_groups = [aws_security_group.plex.id, local.ssh_security_group_id]
# }

# resource "aws_eip" "eip1" {
#   network_interface         = aws_network_interface.interface1.id
#   associate_with_private_ip = aws_network_interface.interface1.private_ip
# }

# resource "aws_eip" "eip2" {
#   network_interface         = aws_network_interface.interface2.id
#   associate_with_private_ip = aws_network_interface.interface2.private_ip
# }