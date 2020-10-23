
# Use AWS Terraform provider
provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}



# Create EC2 instance
resource "aws_instance" "vault" {
  ami                         = "ami-02632c36a441260c2"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key-pr.key_name
  subnet_id                   = aws_subnet.private-subnet-1b.id
  availability_zone           = data.aws_availability_zones.zones.names[1]
  vpc_security_group_ids      = [ aws_security_group.sg-pr.id ]
  associate_public_ip_address = false
  #user_data                   = file("install_docker_prometheus.sh")

	root_block_device {
		volume_type = "gp2"
		delete_on_termination = true
	}

  tags = {
    Name = "Prometheus"
  }
}

resource "aws_instance" "bastion" {

  depends_on = [
		aws_instance.vault,
  ]
  ami                         = "ami-0bb3fad3c0286ebd5"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key-gr.key_name
  subnet_id                   = aws_subnet.public-subnet-1a.id
  availability_zone           = data.aws_availability_zones.zones.names[0]
  vpc_security_group_ids      = [ aws_security_group.sg-gr.id ]
  associate_public_ip_address = true
  user_data                   = file("install_docker_grafana.sh")

	root_block_device {
		volume_type = "gp2"
		delete_on_termination = true
	}

  tags = {
    Name = "Grafana"
  }
}




# Outputs.tf

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
output "vault_private_ip" {
  value = aws_instance.vault.private_ip
}




