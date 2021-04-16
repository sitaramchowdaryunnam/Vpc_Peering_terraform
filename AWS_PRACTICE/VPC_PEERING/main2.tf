#Here please input the credientials of your aws account
provider "aws" {
    alias  = "east-2"
    #aws account IAM user's account access_key
    access_key = "${var.aws_access_key}"
    #aws account IAM user's account secret_key
    secret_key = "${var.aws_secret_key}"
    #aws account region
    region     =  "us-east-2"
}


#Creating a aws_VPC 

resource "aws_vpc" "Black" { 
  #we can create the cidr_block in any required region according to our wish 
  cidr_block = "192.168.0.0/16"
  provider = aws.east-2
  #enabling dns_hostnames
  enable_dns_hostnames = true
  tags       = {
               Name = "Black"
  }
}

# creating an aws_subnet
resource "aws_subnet" "Blackserver" {
  vpc_id     = "${aws_vpc.Black.id}"
  provider = aws.east-2
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "Blacksubnet"

  }
}

#creating an aws_internet_gateway
resource "aws_internet_gateway" "testing_black_gateway" {
  provider = aws.east-2
  vpc_id = "${aws_vpc.Black.id}"
  tags = {
    Name = "Black_IG"
  }
}

#creating an aws_routetable
resource "aws_route_table" "black_routetesting" {
  vpc_id = "${aws_vpc.Black.id}"
  provider = aws.east-2
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.testing_black_gateway.id}"
  }
   route {
    cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.Black_peering_request.id}"
  }
  depends_on                = [aws_vpc_peering_connection.Black_peering_request]

  tags = {
    Name = "${var.Main_Routing_Table}"
  }
}

#creating an aws_route_table_association
resource "aws_route_table_association" "black_routetesting_ass" { 
  provider = aws.east-2
  route_table_id = "${aws_route_table.black_routetesting.id}"
  subnet_id    = "${aws_subnet.Blackserver.id}"
}

#creating aws_security_group
resource "aws_security_group" "Black_allow_tls" {
  provider = aws.east-2
  name        = "Allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.Black.id}"

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
    Name = "Black_allow_tls"
  }
}
