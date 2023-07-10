resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_security_group_rule" "ssh1" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh.id
}

resource "aws_security_group" "plex" {
  name        = "plex"
  description = "Allow Plex inbound traffic"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_security_group_rule" "plex1" {
  type              = "ingress"
  from_port         = 5353
  to_port           = 5353
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.plex.id
}

resource "aws_security_group_rule" "plex2" {
  type              = "ingress"
  from_port         = 1900
  to_port           = 1900
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.plex.id
}

resource "aws_security_group_rule" "plex3" {
  type              = "ingress"
  from_port         = 32400
  to_port           = 32400
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.plex.id
}

resource "aws_security_group_rule" "plex4" {
  type              = "ingress"
  from_port         = 32469
  to_port           = 32469
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.plex.id
}

resource "aws_security_group_rule" "plex5" {
  type              = "ingress"
  from_port         = 8324
  to_port           = 8324
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.plex.id
}

resource "aws_security_group_rule" "plex6" {
  type              = "ingress"
  from_port         = 32410
  to_port           = 32410
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.plex.id
}
