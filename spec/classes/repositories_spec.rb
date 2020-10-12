require 'spec_helper'

describe 'workstation::repositories' do
  let(:repo_params) do
    [
      {
        'path'  => 'some/path',
        'repos' => [
          {
            :source => 'git@github.com:puppetlabs/foo',
          },
          {
            :source     => 'git@github.com:puppetlabs/bar',
            :clone_name => 'bar_1',
          },
        ],
      },
      {
        'path'       => 'some/path',
        'defaults'   => {
          'upstream' => 'puppetlabs',
        },
        'repos' => [
          {
            :source => 'git@github.com:puppetlabs/dingo',
          },
        ],
      },
      {
        'path'  => '/an/absolute/path',
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
      :repository_data => repo_params,
      :identity        => 'an_ssh_id_rsa',
      :user            => 'agituser',
    }
  end

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_workstation__repos('/home/agituser/some/path/[foo, bar_1]') }
  it { is_expected.to contain_workstation__make_p('Generating /home/agituser/some/path for [foo, bar_1]') }
  it { is_expected.to contain_workstation__repos('/home/agituser/some/path/[dingo]') }
  it { is_expected.to contain_workstation__make_p('Generating /home/agituser/some/path for [dingo]') }
  it { is_expected.to contain_workstation__repos('/an/absolute/path/[baz]') }
  it { is_expected.to contain_workstation__make_p('Generating /an/absolute/path for [baz]') }
  it { is_expected.to contain_vcsrepo('/home/agituser/some/path/foo') }
  it { is_expected.to contain_vcsrepo('/home/agituser/some/path/bar_1') }
  it { is_expected.to contain_vcsrepo('/home/agituser/some/path/dingo') }
  it { is_expected.to contain_vcsrepo('/an/absolute/path/baz') }
end
