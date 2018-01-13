require 'spec_helper'

describe 'workstation' do
  let(:params) do
    {
      "account"            => "rspec",
      "repository_sources" => ["git@github.com:some/repo"],
    }
  end

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_class('Rbenv') }
  it { is_expected.to contain_rbenv__build('2.3.1') }
  it { is_expected.to contain_package('git') }
  it { is_expected.to contain_user('rspec') }
  it { is_expected.to contain_vcsrepo('/home/rspec/work/src/repo') }
end
