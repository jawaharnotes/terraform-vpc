locals {
  region   = "ap-south-1"
  vpc_cidr = "10.0.0.0/16"
  env      = "dev"

  azs            = ["ap-south-1a", "ap-south-1b"]
  public_subnets = ["10.0.0.0/19", "10.0.32.0/19"]  #AWS wont assign us subnets , we want to specify them 

  private_subnets = {

    private_1 = {
      cidr = cidrsubnet(local.vpc_cidr, 3, 2)          
      az   = "ap-south-1a"
    }

    private_2 = {
      cidr = cidrsubnet(local.vpc_cidr, 3, 3)
      az   = "ap-south-1b"
    }

  }
  
  create_isolated_subnets = true
  isolated_subnets = {
    isolated_1 = {
      cidr = "10.0.128.0/19"
      az   = "ap-south-1a"
    }
    isolated_2 = {
      cidr = "10.0.160.0/19"
      az   = "ap-south-1b"
    }
  }
  
  ingress_rules = {
    22 = "63.10.10.10/32"
    80 = "0.0.0.0/0"
  }    

}