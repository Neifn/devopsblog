resource "aws_s3_bucket" "remote_states_tf_bucket" {
  bucket = "${var.username}-${var.environment}-${var.global["main_bucket_name"]}"
  acl    = "private"

  tags {
    Environment = "${var.environment}"
  }
}
