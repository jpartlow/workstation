require 'spec_helper'

describe 'workstation::repos' do
  let(:title) { '/some/place' }
  let(:required_params) do
    {
      :repository_sources => repo_params,
      :user               => 'agituser',
    }
  end
  let(:repo_params) do
    [
      {
        :source => 'git@github.com:puppetlabs/foo',
      },
      {
        :source => 'git@github.com:puppetlabs/bar',
      },
      {
        :source     => 'git@github.com:puppetlabs/bar',
        :clone_name => 'bar_1',
      },
    ] 
  end
  let(:params) { required_params }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_workstation__repo('Clone git@github.com:puppetlabs/bar into /some/place') }
  it { is_expected.to contain_workstation__repo('Clone git@github.com:puppetlabs/bar into /some/place as bar_1') }
end
