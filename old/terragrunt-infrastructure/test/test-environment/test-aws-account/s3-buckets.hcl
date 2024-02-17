inputs = {
    s3_buckets = [
        {
        name                                    = "test"
        object_expiration_days                  = 2
        object_prefix                           = "/"
        iam_policy_name                         = "test-policy"
        },
        {
        name                                    = "archive-test"
        object_expiration_days                  = 2
        object_prefix                           = "/"
        iam_policy_name                         = "archive-test-policy"
        }        
    ]
}