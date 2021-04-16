#creating aws_Web_instance
resource "aws_instance" "Whiteserver" {
  ami           =  "ami-0742b4e673072066f"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "laptopkey"
  subnet_id = "${aws_subnet.Webserver.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  private_ip = "10.0.1.100"
  associate_public_ip_address = true	
  tags = {
    Name = "WhiteServer"
  }
}


#creating aws_Web_instance
resource "aws_instance" "Blackserver" {
  provider = aws.east-2
  ami           =  "ami-05d72852800cbf29e"
  instance_type = "t2.micro"
  availability_zone = "us-east-2a"
  key_name = "us-east-2"
  subnet_id = "${aws_subnet.Blackserver.id}"
  vpc_security_group_ids = ["${aws_security_group.Black_allow_tls.id}"]
  private_ip = "192.168.1.100"
  associate_public_ip_address = true	
  tags = {
    Name = "BlackServer"
  }
}
