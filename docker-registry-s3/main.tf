variable "name" {
}

variable "environment" {
}

resource "aws_s3_bucket" "registry" {
  bucket = "${var.name}-${var.environment}-registry"

  tags {
    Name        = "${var.name}-${var.environment}-registry"
    Environment = "${var.environment}"
  }
}

output "arn" {
  value = "${aws_s3_bucket.registry.arn}"
}

output "id" {
  value = "${aws_s3_bucket.registry.id}"
}
