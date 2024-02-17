include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "source//random_id?ref=v1.0"
}
