require 'spec_helper'

describe 'workstation::repo' do
  let(:title) { 'test:repo' }
  let(:required_params) do
    {
      :source      => 'git@github.com:fork/arepo',
      :path        => '/path/to/repo',
      :github_user => 'agituser',
      :identity    => 'an_ssh_id_rsa',
    }
  end
  let(:params) { required_params }

  it { is_expected.to compile.with_all_deps }
  it do
    is_expected.to contain_vcsrepo('/path/to/repo/arepo')
      .with_source('git@github.com:fork/arepo')
      .with_owner('agituser')
      .with_group('agituser')
      .with_user('agituser')
      .with_identity('an_ssh_id_rsa')
  end
  it do
    is_expected.to have_workstation__repo__remote_count(0)
  end

  context 'with a clone name' do
    let(:params) do
      required_params.merge(
        :clone_name => 'foo'
      )
    end

    it do
      is_expected.to contain_vcsrepo('/path/to/repo/foo')
        .with_source('git@github.com:fork/arepo')
    end

    context 'that is empty' do
      let(:params) do
        required_params.merge(
          :clone_name => ''
        )
      end

      it do
        is_expected.to contain_vcsrepo('/path/to/repo/arepo')
          .with_source('git@github.com:fork/arepo')
      end
    end
  end

  context 'with upstream' do
    let(:params) do
      required_params.merge(
        :upstream => 'puppetlabs'
      )
    end

    it do
      is_expected.to contain_workstation__repo__remote('/path/to/repo/arepo:upstream')
        .with_remote('upstream')
        .with_git_source_url('git@github.com:puppetlabs/arepo')
        .with_repo_dir('/path/to/repo/arepo')
        .with_local_user('agituser')
        .with_require('Vcsrepo[/path/to/repo/arepo]')
    end
  end

  context 'with remotes' do
    let(:params) do
      required_params.merge(
        :remotes => [
          'bob',
          'mary',
        ]
      )
    end

    it do
      is_expected.to contain_workstation__repo__remote('/path/to/repo/arepo:bob')
        .with_remote('bob')
        .with_git_source_url('git@github.com:bob/arepo')
        .with_repo_dir('/path/to/repo/arepo')
        .with_local_user('agituser')
        .with_require('Vcsrepo[/path/to/repo/arepo]')
    end

    it do
      is_expected.to contain_workstation__repo__remote('/path/to/repo/arepo:mary')
        .with_remote('mary')
        .with_git_source_url('git@github.com:mary/arepo')
    end
  end

  context 'with checkout_branch' do
    let(:params) do
      required_params.merge(
        :checkout_branch => 'master'
      )
    end

    it do
      is_expected.to contain_exec('Setup branch master for /path/to/repo/arepo')
        .with_command('git checkout -b master -t origin/master')
        .with_unless("git branch | grep -qE '^[ *]+master$'")
        .with_require([])
    end

    it { is_expected.to_not contain_exec('Ensure upstream tracking for master in /path/to/repo/arepo') }

    context 'and upstream' do
      let(:params) do
        required_params.merge(
          :checkout_branch => 'master',
          :upstream        => 'puppetlabs',
        )
      end

      it do
        is_expected.to contain_exec('Setup branch master for /path/to/repo/arepo')
          .with_command('git checkout -b master -t upstream/master')
          .with_unless("git branch | grep -qE '^[ *]+master$'")
          .with_require(["Workstation::Repo::Remote[/path/to/repo/arepo:upstream]"])
      end

      it do
        is_expected.to contain_exec('Ensure upstream tracking for master in /path/to/repo/arepo')
          .with_command('git checkout master && git branch -u upstream/master && git pull && chown -R agituser:agituser /path/to/repo/arepo')
          .with_unless("git config --get branch.master.remote | grep -qE '^upstream$'")
          .with_require('Exec[Setup branch master for /path/to/repo/arepo]')
      end
    end
  end
end
