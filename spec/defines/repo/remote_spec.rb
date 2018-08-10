require 'spec_helper'

describe 'workstation::repo::remote' do
  let(:title) { 'test:remote' }
  let(:params) do
    {
      :repo_dir       => '/path/to/repo',
      :remote         => 'fork',
      :git_source_url => 'git@github.com:fork/repo',
      :local_user     => 'auser',
    }
  end

  it { is_expected.to compile.with_all_deps }
  it do
    is_expected.to contain_exec("Set fork remote for /path/to/repo")
      .with_command("git remote add fork git@github.com:fork/repo")
      .with_unless("git remote | grep -q fork")
  end

  it 'does not fetch' do
    is_expected.to_not contain_exec("Fetch fork")
  end

  context 'with fetch' do
    it do
      params[:fetch_remote] = true
      is_expected.to contain_exec("Fetch fork")
        .with_command("git remote fetch fork")
        .with_unless("git branch -r | grep -qE '^\\s+fork'")
    end
  end
end
