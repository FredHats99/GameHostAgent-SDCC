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
              #!/bin/bash
              set -xe

              # Attendi che apt non sia in uso
              while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
                echo "Attendo che apt si liberi..."
                sleep 5
              done

              # update
              apt-get update -y && apt-get upgrade -y

              # install docker-compose (v1)
              apt-get install -y docker-compose

              # clone repo
              cd /home/ubuntu
              git clone https://github.com/<utente>/<repo>.git GameHostAgent-SDCC
              cd GameHostAgent-SDCC

              # build & run
              docker-compose up -d --build

              # fine
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
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
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