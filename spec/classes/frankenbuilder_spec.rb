require 'spec_helper'

describe 'workstation::frankenbuilder' do
  let(:params) do
    {
      :user => 'rspec',
    }
  end

  context 'no suffixes defined' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/home/rspec/pe_builds') }
    it { is_expected.to have_file_resource_count(4) }
  end

  context 'suffixes defined' do
    let(:params) do
      {
        :user     => 'rspec',
        :suffixes => ['1','2'],
      }
    end

    it { is_expected.to contain_file('/home/rspec/pe_builds') }
    it { is_expected.to have_file_resource_count(6) }
    it do
      is_expected.to contain_file('/home/rspec/work/src/alternates/frankenbuilder_1/.frankenbuilder')
        .with_content(%r{^TEMP_DIR='/tmp/frankenmodules\.1'$})
        .with_content(%r{^pe_acceptance_tests='/home/rspec/work/src/alternates/pe_acceptance_tests_1'$})
    end

    it do
      is_expected.to contain_file('/home/rspec/work/src/alternates/frankenbuilder_2/.frankenbuilder')
        .with_content(%r{^TEMP_DIR='/tmp/frankenmodules\.2'$})
        .with_content(%r{^pe_acceptance_tests='/home/rspec/work/src/alternates/pe_acceptance_tests_2'$})
    end
  end
end
