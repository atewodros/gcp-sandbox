variable "project_id" {
  type = string
}
variable "member" {
  type = string
}
variable "roles" {
  type = list(string)
}

resource "google_project_iam_member" "m" {
  for_each = toset(var.roles)
  project  = var.project_id
  role     = each.value
  member   = var.member
}
