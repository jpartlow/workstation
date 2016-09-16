# Class: workstation::git
# =======================
#
# Ensure git is installed and make an additional prepartions so we can clone repositories.
#
# Parameters
# ----------
#
class workstation::git {
  ensure_packages(['git'])
}
