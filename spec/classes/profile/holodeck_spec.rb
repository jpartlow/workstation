require 'spec_helper'

describe 'workstation::profile::holodeck' do
  let(:params) do
    {
      replicated_license_file: '/some/license.yaml',
      cd4pe_license_file: '/some/cd4pe.json',
    }
  end

  include_context('fake files', { '/some/license.yaml' => 'alicense', '/some/cd4pe.json' => 'acd4pelicense'})

  it { is_expected.to compile.with_all_deps }

  it 'enables centos extras' do
    is_expected.to(
      contain_yumrepo('extras')
        .with_name('extras')
        .with_descr('CentOS-$releasever - Extras')
        .with_enabled(1)
    )
  end

  it 'enables stable' do
    is_expected.to(
      contain_yumrepo('docker-ce-stable').with_enabled(1)
    )
    is_expected.to(
      contain_yumrepo('docker-ce-stable-debuginfo').with_enabled(0)
    )
    is_expected.to(
      contain_yumrepo('docker-ce-stable-source').with_enabled(0)
    )
  end

  it 'disables test' do
    is_expected.to(contain_yumrepo('docker-ce-test').with_enabled(0))
  end

  it 'disables nightly' do
    is_expected.to(contain_yumrepo('docker-ce-nightly').with_enabled(0))
  end

  it 'installs docker engine' do
    is_expected.to(
      contain_package('docker-ce-cli')
        .with_ensure('latest')
        .that_requires(
          [
            'Yumrepo[docker-ce-stable]',
          ]
        )
    )
    is_expected.to(
      contain_package('docker-ce')
        .with_ensure('latest')
        .that_requires(
          [
            'Yumrepo[docker-ce-stable]',
          ]
        )
    )
  end

  it 'enables kubernetes' do
    is_expected.to(
      contain_yumrepo('kubernetes')
        .with_baseurl('https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64')
        .with_enabled(1)
    )
  end

  it 'cleans the yum cache if notified' do
    is_expected.to(contain_exec('yum-clean-all').with_refreshonly(true))
  end

  context('test') do
    let(:params) do
      {
        replicated_license_file: '/some/license.yaml',
        cd4pe_license_file: '/some/cd4pe.json',
        docker_channel: 'test',
      }
    end

    it do
      is_expected.to(
        contain_yumrepo('docker-ce-test').with_enabled(1)
      )
      is_expected.to(
        contain_yumrepo('docker-ce-test-debuginfo').with_enabled(0)
      )
      is_expected.to(
        contain_yumrepo('docker-ce-test-source').with_enabled(0)
      )
      is_expected.to(
        contain_yumrepo('docker-ce-stable').with_enabled(0)
      )
      is_expected.to(
        contain_yumrepo('docker-ce-nightly').with_enabled(0)
      )
    end
  end

  context('source and debuginfo') do
    let(:params) do
      {
        replicated_license_file: '/some/license.yaml',
        cd4pe_license_file: '/some/cd4pe.json',
        enable_debuginfo_repo: true,
        enable_source_repo: true,
      }
    end

    it do
      is_expected.to(
        contain_yumrepo('docker-ce-stable').with_enabled(1)
      )
      is_expected.to(
        contain_yumrepo('docker-ce-stable-debuginfo').with_enabled(1)
      )
      is_expected.to(
        contain_yumrepo('docker-ce-stable-source').with_enabled(1)
      )
      is_expected.to(
        contain_yumrepo('docker-ce-test').with_enabled(0)
      )
      is_expected.to(
        contain_yumrepo('docker-ce-nightly').with_enabled(0)
      )
    end
  end

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
        .with_mode('0640')
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
