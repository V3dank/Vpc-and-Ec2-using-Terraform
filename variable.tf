#======Provider=====
variable "aws_region" {
    default = "us-east-1"
}



#=====Vpc======
variable "vpc_cidr_block" {
    description = "cidr block for vpc"
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_name" {
    description = "vpc name"
    type = string
    default = "terraform-vpc"
}

variable "vpc_creator" {
    description = "Creator for vpc"
    type = string
    default = "Vedank"
}

variable "additionalatags" {
    type = map(string)
    default = {}
  
}


#======Subnet======
variable "subnets" {
    type = map(object({
        cidr_block        = string
        availability_zone = string
        public            = bool
     }))
    default = {
        public-subnet-01 = {
            cidr_block        = "10.0.0.0/18"
            availability_zone = "us-east-1a"
            public            = true
        },
        public-subnet-02 = {
        cidr_block        = "10.0.64.0/18"
        availability_zone = "us-east-1b"
        public            = true
        },
        private-subnet-01 = {
        cidr_block        = "10.0.128.0/18"
        availability_zone = "us-east-1a"
        public            = false
        },
        private-subnet-02 = {
        cidr_block        = "10.0.192.0/18"
        availability_zone = "us-east-1b"
        public            = false
        }
    }
}



#=====Igw=====
variable "igw_name" {
    description = "Name for Igw"
    type = string
    default = "PublicIgw"
}



#======Public_Route_Table======
variable "Public_RT_cidr" {
    description = "cidr_block for Public Route Table"
    type = string
    default = "0.0.0.0/0"
}

variable "Public_RT_name" {
    description = "Name for Public Route table"
    type = string
    default = "PublicRT"
}



#=====Private_Route_Table======
variable "Private_RT_cidr" {
    description = "Cidr for Private Route table"
    type = string
    default = "0.0.0.0/0"
}

variable "Priavte_RT_name" {
    description = "Name for Private Route table"
    type = string
    default = "PrivateRT"
}



#=====EC2_Instance=====
variable "ec2_ami" {
    description = "Ami Value"
    type = string
    default = "ami-09e6f87a47903347c"
}

variable "instance_type" {
    description = "Processor type"
    type = string
    default = "t2.micro"
}

variable "key_name" {
    description = "Key Pair"
    type = string
    default = "Test_Key_1"
}

variable "instance_name" {
    description = "Name of instance"
    type = string
    default = "Public_EC2"
}


#======Security_Groups======
variable "SG_name" {
    description = "Name of Security Groups"
    type = string
    default = "SG_TF"
}

# Ingress rules (allow incoming traffic)
variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH"
    }
  ]
}

# Egress rules (allow outgoing traffic)
variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]
}
