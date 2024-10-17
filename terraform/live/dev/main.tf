provider "google" {
  region = local.region
}

locals {
  org_name        = "swye360"
  app_name        = "stdnt-attrtn"
  env_name        = "dev"
  region          = "us-east-1"
  cpu             = 1024
  memory          = 3072
  container_image_inf = "849423638545.dkr.ecr.us-east-1.amazonaws.com/swye/inference"
  container_image_train = "849423638545.dkr.ecr.us-east-1.amazonaws.com/swye/train"
  container_port  = 8000
  availability_zones = {1: "us-east-1a", 2: "us-east-1b"}
  vpc_cidr_block = "10.0.0.0/22"  # could probably do with a smaller block here
  service-memory = 2048
  service-cpu = 512
  service_role_name = "NewMath"  # now its NewMath
  service_role_arn = "arn:aws:iam::849423638545:role/NewMath"
}

module "inference" {
  source = "../../modules/cloudrun"
  aws_security_group_id = module.vpc.security_group_id
  container_image = local.container_image_inf
  container_port = local.container_port
  container_protocol = "tcp"
  cpu = local.service-cpu
  memory = local.service-memory
  ecs_task_execution_role_arn = local.service_role_arn
  ecs_task_execution_role_name = local.service_role_name
  log_group_name = module.cloudwatch.log_group_name
  region = local.region
  subnets = module.vpc.main_subnets
  app_name = local.app_name
  env_name = local.env_name
  org_name = local.org_name
  target_group_arn = module.alb.target_group_arn
}

module "job-creator" {
  source = "../../modules/cloudfunctions"
  bucket_arn = module.s3.s3_bucket_arn
  role_arn = local.service_role_arn
  role_name = local.service_role_name
  log_group_name = module.cloudwatch.log_group_name
  app_name = local.app_name
  org_name = local.org_name
  env_name = local.env_name
}

module "batch_training" {
  source = "../../modules/batch"

  compute_environment_name = "${local.app_name}-${local.env_name}-compute-env"#"swye-compute-env-tf-2"
  job_queue_name           = "${local.app_name}-${local.env_name}-job-queue"
  job_definition_name      = "${local.app_name}-${local.env_name}-train-def"
  max_vcpus           = 16
  subnets             = module.vpc.main_subnets
  security_group_ids  = [module.vpc.security_group_id]

  queue_priority      = 1

  job_image           = local.container_image_train
  job_vcpus           = 1
  job_memory          = 2048
  job_command         = ["python", "swye360samodel/Train/train.py", "Ref::file_key"]
  job_environment     = [{ name = "ENV_VAR", value = "example" }]
  job_attempts        = 1
  job_timeout         = 1800
  app_name = local.app_name
  org_name = local.org_name
  service_role_arn = local.service_role_arn
  service_role_name = local.service_role_name
}

# The s3 bucket for data input
module "cloudstorage" {
  source = "../../modules/cloudstorage"
  app_name = local.app_name
  env_name = local.env_name
  org_name = local.env_name
  type = "data"
  lambda_func_arn = module.lambda-job-creator.func_arn
}

module "vpc" {
  source = "../../modules/vpc"
  container_port = local.container_port
  app_name = local.app_name
  env_name = local.env_name
  org_name = local.env_name
  availability_zones = local.availability_zones
  cidr_block = local.vpc_cidr_block
  region = local.region
}
