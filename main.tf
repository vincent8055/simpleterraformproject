# Create VPC
 resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "VincentTFVPC"
  }
 }

 # Create subnets in two AZs
 resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet1"
  }
 }

 resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet2"
  }
 }

# Create internet gateway
 resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyIGW"
  }
 }

# Attach internet gateway to VPC
 resource "aws_internet_gateway_attachment" "my_attachment" {
  vpc_id             = aws_vpc.my_vpc.id
  internet_gateway_id = aws_internet_gateway.my_igw.id
 }

# Create route table to associate to public subnet 
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

# Create security group for EC2 instance
resource "aws_security_group" "my_security_group" {
  name        = "MySecurityGroup"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provision EC2 instance with Apache web server
resource "aws_instance" "my_instance" {
  ami           = "ami-0123456789abcdef0"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "VincentTFEC2Instance"
  }
}

# Provision EC2 instance with Ansible server
resource "aws_instance" "my_ansibleinstance" {
  ami           = "ami-0123456789abcdef0"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install pip -y
              sudo python3 -m pip install --user ansible
              EOF

  tags = {
    Name = "VincentAnsibleServer"
  }
}