require 'spec_helper'

describe 'workstation' do
  let(:repo_params) do
    [
      {
        'path'  => 'some/path',
        'repos' => [
          {
            :source => 'git@github.com:puppetlabs/foo',
          },
          {
            :source => 'git@github.com:puppetlabs/bar',
          },
        ],
      },
      {
        'path'  => 'some/other/path',
        'repos' => [
          {
            :source => 'git@github.com:puppetlabs/baz',
          },
        ],
      },
    ]
  end
  let(:params) do
    {
      "account"            => "rspec",
      "repository_data" => repo_params,
      "ssh_public_keys"        => [
        [ 'foo', 'abcde12345' ]
      ]
    }
  end

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_class('Rbenv') }
  it { is_expected.to contain_rbenv__build('2.4.3') }
  it { is_expected.to contain_package('git') }
  it { is_expected.to contain_user('rspec') }
  it { is_expected.to contain_vcsrepo('/home/rspec/some/path/foo') }
  it { is_expected.to contain_vcsrepo('/home/rspec/some/path/bar') }
  it { is_expected.to contain_vcsrepo('/home/rspec/some/other/path/baz') }
  it { is_expected.to contain_vcsrepo('/home/rspec/.dotfiles') }
end
