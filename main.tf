provider "aws" {
    region     = "us-west-2"
    access_key = "my-access-key"
    secret_key = "my-secret-key"
  }
#create vpc
resource "aws_vpc" "myfirstvpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "myvpc1"
    }
}
#create public subnet
resource "aws_subnet" "public_subnet"{
    vpc_id = aws_vpc.myfirstvpc.id
    cidr_block ="10.0.0.0/20"
    availability_zone = var.zone1
    map_public_ip_on_launch ="true"
    tags = {
        Name = "public_subnet"
    }
}
#create private subnet
resource "aws_subnet" "private_subnet"{
    vpc_id = aws_vpc.myfirstvpc.id
    cidr_block = "10.0.24.0/22"
    availability_zone = var.zone3
    map_public_ip_on_launch = "false"
    tags = {
        Name = "private_subnet"
    }
}
#create internetgateway
resource "aws_internet_gateway" "my_ig"{
    vpc_id = aws_vpc.myfirstvpc.id
    tags = {
        Name = "my_ig"
    }
}
#create public_route_table
resource "aws_route_table" "my_public_rt"{
    vpc_id = aws_vpc.myfirstvpc.id
    tags ={
        Name = "public_rt"
    }
}
#add route to route table
resource "aws_route" "my_public_route"{
    route_table_id = aws_route_table.my_public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_ig.id
}
#create private_route_table
resource "aws_route_table" "my_private_rt"{
    vpc_id= aws_vpc.myfirstvpc.id
    tags = {
        Name = "private_rt"
    }
}
#associate private_subnet
resource "aws_route_table_association" "private_association_subnet"{
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.my_private_rt.id
}
#associate public_subnet
resource "aws_route_table_association" "public_association_subnet"{
    subnet_id =aws_subnet.public_subnet.id
    route_table_id = aws_route_table.my_public_rt.id
}
#create NACL
resource "aws_network_acl" "private_nacl"{
    vpc_id = aws_vpc.myfirstvpc.id
    ingress{
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
        rule_no = 100
        action = "allow"
        from_port = 0
        to_port = 0
    }
    egress{
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
        rule_no = 100
        action = "allow"
        from_port = 0
        to_port = 0
    }

    tags = {
        Name = "private_nacl"
    }
}
resource "aws_network_acl" "public_nacl"{
    vpc_id = aws_vpc.myfirstvpc.id

    ingress{
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
        rule_no = 100
        action = "allow"
        from_port = 0
        to_port = 0
    }
    egress{
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
        rule_no = 100
        action = "allow"
        from_port = 0
        to_port = 0
    }
    tags = {
        Name = "public_nacl"
    }
}
resource "aws_network_acl_association" "public_nacl_associaation"{
    network_acl_id = aws_network_acl.public_nacl.id
    subnet_id = aws_subnet.public_subnet.id
}
resource "aws_network_acl_association" "private_nacl_association" {
    network_acl_id = aws_network_acl.private_nacl.id
    subnet_id = aws_subnet.private_subnet.id
}
#create security groups
resource "aws_security_group" "my_sg"{
    vpc_id = aws_vpc.myfirstvpc.id
    description = "allow SSH port"

    ingress{
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress{
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "my_sg_vpc"
    }
}

#create instance...
resource "aws_instance" "ubuntu_20-04"{
    ami = "ami-024e6efaf93d85776"
    instance_type = "t2.micro"
    key_name = "123123"
    subnet_id = aws_subnet.public_subnet.id
    count = 1
    security_groups = [aws_security_group.my_sg.id]
    tags ={
        Name = "first_instance"
    }
	user_data = "${file("user_data.sh")}"
}



