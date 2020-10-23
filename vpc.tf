# -- Creating vpc

resource "aws_vpc" "pg-vpc" {
	cidr_block       = "10.8.0.0/16"
	instance_tenancy = "default"
	enable_dns_hostnames = "true"

	tags = {
  		Name = "test-vpc"
  	}
}

# -- Creating internet-gateway

resource "aws_internet_gateway" "pg-igw" {
	vpc_id = aws_vpc.pg-vpc.id

	tags = {
  		Name = "test-igw"
  	}
}

# -- Creating subnet

data "aws_availability_zones" "zones" {
	state = "available"
}

# -- Creating public subnet

resource "aws_subnet" "public-subnet-1a" {
	availability_zone = data.aws_availability_zones.zones.names[0]
	cidr_block = "10.8.1.0/24"
	vpc_id = aws_vpc.pg-vpc.id
	map_public_ip_on_launch = "true"

	tags = {
		Name = "public-subnet-1a"
	}
}

# -- Creating private subnet

resource "aws_subnet" "private-subnet-1b" {
	availability_zone = data.aws_availability_zones.zones.names[1]
	cidr_block = "10.8.2.0/24"
	vpc_id = aws_vpc.pg-vpc.id

	tags = {
		Name = "private-subnet-1b"
	}
}

# -- Create route table

resource "aws_route_table" "pg-route-igw" {
	vpc_id = aws_vpc.pg-vpc.id

	route {
  		cidr_block = "0.0.0.0/0"
  		gateway_id = aws_internet_gateway.pg-igw.id
  	}

	tags = {
    		Name = "pg-route-igw"
  	}
}

# -- Subnet Association

resource "aws_route_table_association" "subnet-1a-asso" {
		subnet_id      = aws_subnet.public-subnet-1a.id
  		route_table_id = aws_route_table.pg-route-igw.id
}

# -- Creating Security Groups for grafana

resource "aws_security_group" "sg-gr" {
	name        = "grafana-sg"
  	description = "Allow TLS inbound traffic"
  	vpc_id      = aws_vpc.pg-vpc.id


  	ingress {
    		description = "SSH"
    		from_port   = 22
    		to_port     = 22
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}

  	ingress {
    		description = "grafana-port"
    		from_port   = 3000
    		to_port     = 3000
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}

  	egress {
    		from_port   = 0
    		to_port     = 0
    		protocol    = "-1"
    		cidr_blocks = ["0.0.0.0/0"]
  	}

  	tags = {
    		Name = "grafana-sg"
  	}
}

# -- Creating Security Groups for Prometheus

resource "aws_security_group" "sg-pr" {
	depends_on = [
		aws_security_group.sg-gr,
  	]
	name        = "prometheus-sg"
  	description = "Allow TLS inbound traffic"
  	vpc_id      = aws_vpc.pg-vpc.id


   	ingress {
    		description = "SSH"
    		from_port   = 22
    		to_port     = 22
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}

  	ingress {
    		description = "Prometheus-port"
    		from_port   = 9090
    		to_port     = 9090
    		protocol    = "tcp"
    		security_groups = [ aws_security_group.sg-gr.id ]
  	}

  	egress {
    		from_port   = 0
    		to_port     = 0
    		protocol    = "-1"
    		cidr_blocks = ["0.0.0.0/0"]
  	}

  	tags = {
    		Name = "prometheus-sg"
        	}
}
