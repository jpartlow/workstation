source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['~> 5.5']
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '~> 2.7'
gem 'rspec-puppet', '~> 2.6'
gem 'puppet-lint', '~> 2.0'
gem 'facter', '~> 2.0'

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
