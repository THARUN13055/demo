module "securitygroup" {
	security_groups = {
    loadbalancer_sg = {
      name        = "Loadbalancer"
      description = "Security group for Loadbalancer"

      ingress = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]

      tags = {
        Name = "Loadbalancer"
      }
    },
    webserver_sg = {
      name        = "Webserver"
      description = "Security group for Webserver"
      

      ingress = [
        {
          from_port            = 443
          to_port              = 443
          protocol             = "tcp"
          security_groups      = [module.security_group.loadbalancer_sg.id]
        }
      ]

      tags = {
        Name = "Webserver"
      }
    },
    appserver_sg = {
      name        = "AppServer"
      description = "Security group for AppServer"
    

      ingress = [
        {
          from_port            = 5000
          to_port              = 5000
          protocol             = "tcp"
          security_groups      = [module.security_group.webserver_sg.id]
        },
        {
          from_port            = 8000
          to_port              = 8000
          protocol             = "tcp"
          security_groups      = [module.security_group.webserver_sg.id]
        }
      ]

      tags = {
        Name = "AppServer"
      }
    },
    dbserver_sg = {
      name        = "DBServer"
      description = "Security group for DBServer"
      

      ingress = [
        {
          from_port            = 3306
          to_port              = 3306
          protocol             = "tcp"
          security_groups      = [module.security_group.appserver_sg.id]
        }
      ]

      tags = {
        Name = "DBServer"
      }
    }
  }


}

# variable.tf

variable "security_groups" {
  type = map(object({
    name        = string
    description = string
    ingress     = list(object({
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = list(string)
      security_groups  = list(string)
    }))
    tags        = map(string)
  }))

/network/security.tf
  #Create Security Group with Ingress Rules
resource "aws_security_group" "security_groups_ingress" {
    for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id
  tags = merge(var.tags, each.value.tags)


  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol

      cidr_blocks     = can(ingress.value.cidr_blocks) ? ingress.value.cidr_blocks : null
      security_groups = can(ingress.value.security_groups) ? ingress.value.security_groups : null
    }
  }
}
