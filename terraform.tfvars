# This file is intentionally left without environment-specific values.
# Use qa.tfvars or prod.tfvars explicitly:
#   terraform plan -var-file=qa.tfvars
#   terraform plan -var-file=prod.tfvars
#
# admin_password is never stored here — set TF_VAR_admin_password in your
# shell or let the CI workflow inject it from secrets.
