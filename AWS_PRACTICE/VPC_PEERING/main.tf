#Here please input the credientials of your aws account
provider "aws" {
    #aws account IAM user's account access_key
    access_key = "${var.aws_access_key}"
    #aws account IAM user's account secret_key
    secret_key = "${var.aws_secret_key}"
    #aws account region
    region     =  "us-east-1"
}

#Creating a aws_VPC 

resource "aws_vpc" "white" { 
  #we can create the cidr_block in any required region according to our wish 
  cidr_block = "10.0.0.0/16"
  #enabling dns_hostnames
  enable_dns_hostnames = true
  tags       = {
               Name = "white"
               Env  = "Testing-vpc"
  }
}

# creating an aws_subnet
resource "aws_subnet" "Webserver" {
  vpc_id     = "${aws_vpc.white.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "whitesubnet"

  }
}

#creating an aws_internet_gateway
resource "aws_internet_gateway" "testing_gateway" {
  vpc_id = "${aws_vpc.white.id}"

  tags = {
    Name = "${var.IGW_name}"
  }
}

#creating an aws_routetable
resource "aws_route_table" "routetesting" {
  vpc_id = "${aws_vpc.white.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.testing_gateway.id}"
  }
  route {
    cidr_block = "192.168.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.Black_peering_request.id}"
  }
  depends_on                = [aws_vpc_peering_connection.Black_peering_request]

  tags = {
    Name = "${var.Main_Routing_Table}"
  }
}

#creating an aws_route_table_association
resource "aws_route_table_association" "routetesting_ass" { 
  route_table_id = "${aws_route_table.routetesting.id}"
  subnet_id    = "${aws_subnet.Webserver.id}"

}

data "aws_caller_identity" "peer" {
  provider = aws.east-2
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "Black_peering_request" {
  vpc_id        = aws_vpc.white.id
  peer_vpc_id   = aws_vpc.Black.id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  peer_region   = "us-east-2"
  auto_accept   = false

  tags = {
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peering_accept" {
  provider                  = aws.east-2
  vpc_peering_connection_id = aws_vpc_peering_connection.Black_peering_request.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

# #creating an aws_vpc_peering
# resource "aws_vpc_peering_connection" "foo" {
#   peer_owner_id = var.peer_owner_id
#   peer_vpc_id   = aws_vpc.Black.id
#   vpc_id        = aws_vpc.white.id
#   peer_region   = "us-east-2"
  

#   tags = {
#     Name = "VPC Peering between Black and white"
#   }
# }

#creating aws_security_group
resource "aws_security_group" "allow_tls" {
  name        = "Allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.white.id}"

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
