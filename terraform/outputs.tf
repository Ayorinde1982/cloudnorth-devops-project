output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_public_ip" {
  value = aws_instance.backend.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.static_content.bucket
}

output "db_endpoint" {
  value = aws_db_instance.cloudnorth_db.endpoint
}
