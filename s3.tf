resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "vpc-backend-bucket"  # Replace with your desired unique bucket name
}
# tags = {
#   Name = "My bucket"
#   Environment = "Prd"
#   }
#   lifecycle {
#     prevent_destroy = true
#   }
#   versioning {
#     enabled = true
#   }
# }