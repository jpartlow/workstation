require 'spec_helper'

describe 'workstation::profile::holodeck' do
  let(:params) do
    {
      replicated_licenses: ['/some/license.yaml'],
      cd4pe_license_file: '/some/cd4pe.json',
      license_links: {
        'replicated': ['/some/license-link.yaml'],
        'cd4pe': ['/some/cd4pe-link.json'],
      }
    }
  end

  include_context('fake files', { '/some/license.yaml' => 'alicense', '/some/cd4pe.json' => 'acd4pelicense'})

  it { is_expected.to compile.with_all_deps }

  it 'installs krew' do
    is_expected.to(
      contain_exec('krew-install')
        .with_user('centos')
    )
  end

  it 'adds the gitlab chart repo' do
    is_expected.to contain_exec('add-helm-repo-gitlab')
  end

  it 'adds other chart repos' do
    params[:additional_chart_repos] = [
      { 'name' => 'test', 'url' => 'https://some.test' },
    ]
    is_expected.to contain_exec('add-helm-repo-gitlab')
    is_expected.to contain_exec('add-helm-repo-test')
  end

  it 'installs jq' do
    is_expected.to contain_package('jq')
  end

  it 'installs extra packages if requested' do
    params[:additional_packages] = ['thing']
    is_expected.to contain_package('jq')
    is_expected.to contain_package('thing')
  end

  it 'transfers the license file' do
    params[:dev_user] = 'test'
    is_expected.to(
      contain_file('/home/test/license.yaml')
        .with_ensure('present')
        .with_content('alicense')
        .with_mode('0600')
        .with_owner('test')
        .with_group('test')
    )
  end

  it 'creates links to it' do
    params[:license_links] = { 'replicated' => ['/home/centos/linked/license.yaml'] }
    is_expected.to(
      contain_file('/home/centos/linked/license.yaml')
        .with_ensure('link')
        .with_target('/home/centos/license.yaml')
    )
  end
end
