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
  end
end
