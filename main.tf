provider "aws" {
region     = var.aws_region


}


# VPC


resource "aws_vpc" "vpc1" {
  cidr_block       = "11.0.0.0/16"
  tags = {
    Name = "vpc1"
  }
}
#  private subnet


resource "aws_subnet" "private-subnet" {
  cidr_block        = "11.0.3.0/24"
  vpc_id            = aws_vpc.vpc1.id
  tags = {
   Name = "private-subnet"
   }
}


#  public subnet

         
resource "aws_subnet" "pub-subnet" {
  cidr_block        = "11.0.2.0/24"
  vpc_id            = aws_vpc.vpc1.id
  map_public_ip_on_launch = "true"
  tags = {
   Name = "pub-subnet"
   }
}



# Create Internet Gateway 


resource "aws_internet_gateway" "vpc1_igw" {
 vpc_id = aws_vpc.vpc1.id
 tags = {
    Name = "vpc1-igw"
 }
}


# create elastic ip
resource "aws_eip" "elastic"{
	vpc= true
}






#   NAT Gateway

resource "aws_nat_gateway" "vpc1-ngw" {
  allocation_id = aws_eip.elastic.id
  subnet_id = aws_subnet.pub-subnet.id
  tags = {
      Name = "vpc1-ngw"
  }
}


# Routing 


resource "aws_route_table" "vpc1_pub_route" {
  vpc_id =  aws_vpc.vpc1.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.vpc1_igw.id
  }

   tags = {
       Name = "vpc1_pub_route"
   }
}


resource "aws_default_route_table" "vpc1-default-route" {
  default_route_table_id = aws_vpc.vpc1.default_route_table_id
  tags = {
      Name = "vpc1-default-route"
  }
}



# Subnet Association

resource "aws_route_table_association" "association" {
  subnet_id = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.vpc1_pub_route.id
}


resource "aws_route_table_association" "association2" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_vpc.vpc1.default_route_table_id
}


resource "aws_instance" "instances" {
  count         = "2"
  ami           = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private-subnet.id
  tags = {
    Name = "Instance ${count.index}"
  }
}


