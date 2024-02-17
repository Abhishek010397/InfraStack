/*
 * This module will create one or more ec2 Instances and IAM Instance Profile Role that give write access to the bucket(s).
*/
/*Example*/
#module "ec2_instance" {
#  source  = "terraform-aws-modules/ec2-instance/aws"
#
#  for_each = toset(["one", "two", "three"])
#
#  name = "instance-${each.key}"
#
#  instance_type          = "t2.micro"
#  key_name               = "user1"
#  monitoring             = true
#  vpc_security_group_ids = ["sg-12345678"]
#  subnet_id              = "subnet-eddcdzz4"
#
#  tags = {
#    Terraform   = "true"
#    Environment = "dev"
#  }
#}


data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance_role" {
  name               = var.instance_role_name
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "instance_role_policy_attach" {
  for_each   = toset(var.instance_policy_arn)
  role       = aws_iam_role.instance_role.name
  policy_arn = each.key
}

resource "aws_iam_instance_profile" "instance_profile_role" {
  name = var.instance_profile_role_name
  role = aws_iam_role.instance_role.name
  tags = var.tags
}
