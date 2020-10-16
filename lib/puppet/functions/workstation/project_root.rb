# @return [String] Absolute path to the bolt project root directory.
Puppet::Functions.create_function('workstation::project_root') do
  def project_root
    File.expand_path(File.join(__dir__, '..', '..', '..', '..'))
  end
end
