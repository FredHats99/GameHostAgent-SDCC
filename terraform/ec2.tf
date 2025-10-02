terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }
}
provider "aws" {
        region = "eu-west-1"
}

resource "aws_instance" "game_host" {
  ami = "ami-00f569d5adf6452bb"
  instance_type = "t3.micro"
  key_name = "gamecloud-key"  # deve esistere su AWS EC2 > Key pairs

  tags = {
    Name = "GameHostAgent"
  }

  vpc_security_group_ids = [aws_security_group.game_host_sg.id]

  user_data = <<-EOF
  #cloud-config
  package_update: true
  packages:
    - git
    - docker.io
    - docker-compose

  runcmd:
    - [ systemctl, enable, docker ]
    - [ usermod, -aG, docker, ubuntu ]
    - [ git, clone, https://github.com/FredHats99/GameHostAgent-SDCC.git, /home/ubuntu/GameHostAgent-SDCC ]
    - [ bash, -c, "cd /home/ubuntu/GameHostAgent-SDCC && docker-compose up -d --build" ]
  EOF


  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host = self.public_ip
    }
  }
}

resource "aws_security_group" "game_host_sg" {
  name = "game-host-sg"
  description = "Allow SSH, HTTP, and WebRTC ports"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Gateway API"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Signaling"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Client demo"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Game Host Agent"
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WebRTC mdeia (UDP 10000-20000)"
    from_port = 10000
    to_port = 20000
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

output "gamehost_public_ip" {
  description = "IP pubblico dell'istanza EC2"
  value = aws_instance.game_host.public_ip
}