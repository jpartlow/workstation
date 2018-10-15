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
      ],
      "gems" => [
        'foo',
      ],
      "packages" => [
        'bar',
      ],
    }
  end
  let(:os_major) { '18.04' }
  let(:facts) do
    {
      'os'        => {
        'release' => {
          'major' => os_major,
        },
      },
    }
  end

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_class('Rbenv') }
  it { is_expected.to contain_rbenv__build('2.5.1') }
  it { is_expected.to contain_rbenv__gem('foo on 2.5.1') }
  it { is_expected.to contain_package('git') }
  it { is_expected.to contain_user('rspec') }

  it { is_expected.to contain_file('/home/rspec/work/src') }
  it { is_expected.to contain_file('/home/rspec/work/src/pe-modules') }
  it { is_expected.to contain_file('/home/rspec/work/src/puppetlabs') }
  it { is_expected.to contain_file('/home/rspec/work/src/alternates') }
  it { is_expected.to contain_file('/home/rspec/work/src/other') }

  it { is_expected.to contain_vcsrepo('/home/rspec/some/path/foo') }
  it { is_expected.to contain_vcsrepo('/home/rspec/some/path/bar') }
  it { is_expected.to contain_vcsrepo('/home/rspec/some/other/path/baz') }

  it { is_expected.to contain_vcsrepo('/home/rspec/.dotfiles') }

  it do
    is_expected.to contain_class('workstation::vim')
      .that_requires('Class[Workstation::Repositories]')
  end

  it { is_expected.to contain_package('bar') }

  it do
    is_expected.to contain_class('workstation::lein')
      .that_requires([
        'Class[Workstation::Packages]',
        'File[/home/rspec/bin]',
      ])
  end

  context 'with minimal params' do
    let(:params) do
      {
        "account"            => "rspec",
        "repository_data" => repo_params,
        "ssh_public_keys"        => [
          [ 'foo', 'abcde12345' ]
        ],
      }
    end

    it { is_expected.to compile.with_all_deps }
  end
end
