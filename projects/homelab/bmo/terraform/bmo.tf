resource "aws_instance" "bmo" {
  ami             = "ami-06ca3ca175f37dd66" # Replace with your desired AMI ID
  instance_type   = "t3.medium"
  # security_groups = [aws_security_group.plex.id, aws_security_group.ssh.id]
  user_data       = local.cloud_config
  key_name        = "bmo"

  root_block_device {
    volume_size = 8 # Default root volume size is 8 GB, you can change it if needed
  }

  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_size = 125
  }

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.interface1.id
  }

  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.interface2.id
  }
}

resource "aws_network_interface" "interface1" {
  subnet_id       = "subnet-0cce7cd1eb4c1f5dc"
  security_groups = [ aws_security_group.plex.id, "sg-01be6bcdc143cffc1" ]
  depends_on = [ aws_security_group.plex, aws_security_group.ssh ]

  # attachment {
  #   instance     = aws_instance.bmo.id
  #   device_index = 1
  # }
}

resource "aws_network_interface" "interface2" {
  subnet_id = "subnet-0cce7cd1eb4c1f5dc"
  security_groups = [ aws_security_group.plex.id, "sg-01be6bcdc143cffc1" ]
}

resource "aws_eip" "eip1" {
  network_interface = aws_network_interface.interface1.id
  associate_with_private_ip = aws_network_interface.interface1.private_ip
}

resource "aws_eip" "eip2" {
  network_interface         = aws_network_interface.interface2.id
  associate_with_private_ip = aws_network_interface.interface2.private_ip
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Homelab VPC"
  }
}

