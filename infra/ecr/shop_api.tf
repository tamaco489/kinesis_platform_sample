resource "aws_ecr_repository" "shop_api" {
  name                 = local.shop_api
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = local.shop_api }
}

resource "aws_ecr_lifecycle_policy" "shop_api" {
  repository = aws_ecr_repository.shop_api.name
  policy = jsonencode(
    {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Keep 5 versioned images, when the 6th is uploaded, delete the oldest ones in order",
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["shop_api_v"],
            "countType" : "imageCountMoreThan",
            "countNumber" : 5
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
          "rulePriority" : 2,
          "description" : "Keep the latest image with the stg tag",
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["stg"], // stg tagged images
            "countType" : "imageCountMoreThan",
            "countNumber" : 1, // keep latest generation
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
          "rulePriority" : 3,
          "description" : "Delete images that have not been tagged after 3 days",
          "selection" : {
            "tagStatus" : "untagged",
            "countType" : "sinceImagePushed",
            "countUnit" : "days",
            "countNumber" : 3
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
          "rulePriority" : 4,
          "description" : "Delete images that have been tagged after 7 days",
          "selection" : {
            "tagStatus" : "any",
            "countType" : "sinceImagePushed",
            "countUnit" : "days",
            "countNumber" : 7
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  )
}
