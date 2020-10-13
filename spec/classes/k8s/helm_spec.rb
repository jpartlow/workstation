require 'spec_helper'

describe 'workstation::k8s::helm' do
  let(:params) { {} }
  let(:chart_repos) do
    [
      { 'name' => 'test', 'url' => 'https://some.test' },
    ]
  end

  it { is_expected.to compile.with_all_deps }

  it 'installs helm' do
    is_expected.to contain_exec('install-helm')
  end

  it 'adds repositories' do
    params[:chart_repos] = chart_repos
    is_expected.to(
      contain_exec('add-helm-repo-test')
        .with_command('helm repo add test https://some.test')
        .with_unless("helm repo list | grep -q 'https://some.test'")
    )
  end

  it 'updates helm repos' do
    is_expected.to contain_exec('helm-update')
  end
end
