require 'spec_helper'

describe 'workstation::frankenbuilder' do
  let(:params) do
    {
      :user => 'rspec',
    }
  end

  it { is_expected.to compile.with_all_deps }
  it do
    is_expected.to contain_file('/home/rspec/work/src/frankenbuilder/.frankenbuilder')
      .with_content(%r{^TEMP_DIR='/tmp/frankenmodules\.0'$})
      .with_content(%r{^pe_acceptance_tests='/home/rspec/work/src/pe_acceptance_tests'$})
  end

  it do
    is_expected.to contain_file('/home/rspec/work/src/alternates/frankenbuilder_2/.frankenbuilder')
      .with_content(%r{^TEMP_DIR='/tmp/frankenmodules\.2'$})
      .with_content(%r{^pe_acceptance_tests='/home/rspec/work/src/alternates/pe_acceptance_tests_2'$})
  end
end
