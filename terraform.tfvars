# Environment settings
environment = "dev"
project_name = "shopping-site"

# Database settings (use AWS Secrets Manager in production)
db_username = "admin"
db_password = "password123"

# Instance settings
instance_type = "t3.micro"
db_instance_class = "db.t3.micro"

# Auto Scaling settings
min_size = 1
max_size = 10
desired_capacity = 2