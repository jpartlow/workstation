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
      "account"         => "rspec",
      "repository_data" => repo_params,
      "ssh_public_keys" => [
        'foo.pub',
      ],
      "gems" => [
        'foo',
      ],
      "packages" => [
        'bar',
      ],
      "package_repositories" => [
        {
          'repo_package_url' => 'http://foo/arepo-bionic.deb',
          'packages'         => [
            'baz',
            'biff',
          ]
        }
      ]
    }
  end
  let(:os_major) { '18.04' }
  let(:facts) do
    {
      'os'        => {
        'release' => {
          'major' => os_major,
        },
        'family' => 'Debian',
      },
    }
  end

  include_context('fake files', { '/home/rspec/.ssh/foo.pub' => 'ssh-rsa abcde foo' })

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_class('Rbenv') }
  it { is_expected.to contain_rbenv__build('2.5.1') }
  it { is_expected.to contain_rbenv__gem('foo on 2.5.1') }
  it { is_expected.to contain_package('git') }
  it { is_expected.to contain_user('rspec') }

  it { is_expected.to contain_file('/home/rspec/some') }
  it { is_expected.to contain_file('/home/rspec/some/path') }
  it { is_expected.to contain_vcsrepo('/home/rspec/some/path/foo') }
  it { is_expected.to contain_vcsrepo('/home/rspec/some/path/bar') }
  it { is_expected.to contain_vcsrepo('/home/rspec/some/other/path/baz') }

  it { is_expected.to contain_vcsrepo('/home/rspec/.dotfiles') }

  it { is_expected.to contain_class('workstation::vim') }

  it { is_expected.to contain_package('bar') }

  it { is_expected.to contain_apt__key('puppetlabs') }
  it { is_expected.to contain_exec('install arepo repository package') }
  it { is_expected.to contain_package('baz') }
  it { is_expected.to contain_package('biff') }

  context 'with minimal params' do
    let(:params) do
      {
        "account"            => "rspec",
        "repository_data" => repo_params,
        "ssh_public_keys"        => [
          'foo.pub'
        ],
      }
    end

    it { is_expected.to compile.with_all_deps }
  end
end
