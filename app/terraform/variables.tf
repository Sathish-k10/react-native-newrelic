variable "region" {
  default     = "ap-south-1"
  description = "The AWS region where resources will be created."
}
variable "new_relic_region" {
  default     = "US"
  description = "The New Relic region where resources will be created."
}
variable "new_relic_account_id" {
  default     = "4737385"
  description = "The New Relic account ID."
}
variable "new_relic_destination_id" {
  default     = "e2b0df6a-aceb-4861-be93-05b0fa5a3a78"
  description = "The New Relic destination ID."
}
variable "new_relic_channel_id" {
  default     = "C07RJTF39LN"
  description = "The New Relic channel ID."
}
