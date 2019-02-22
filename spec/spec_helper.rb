require 'pry-byebug'

RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  config.default_facts = {
    :osfamily        => 'Debian',
    :operatingsystem => 'Ubuntu',
    :puppetversion   => '5.5.1',
  }
end
