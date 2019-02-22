require 'pry-byebug'

RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.shared_context('fake ssh public key') do |path, contents|
  before(:each) do
    unless @_mock_puppet_file_initialized
      allow(Puppet::FileSystem).to receive(:exist?).and_call_original
      allow(Puppet::FileSystem).to receive(:read_preserve_line_endings).and_call_original
      @_mock_puppet_file_initialized = true
    end
    allow(Puppet::FileSystem).to receive(:exist?).with(path).and_return(true)
    allow(Puppet::FileSystem).to receive(:read_preserve_line_endings).with(path).and_return(contents)
  end
end

RSpec.configure do |config|
  config.default_facts = {
    :osfamily        => 'Debian',
    :operatingsystem => 'Ubuntu',
    :puppetversion   => '5.5.1',
  }
end
