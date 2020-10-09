require 'spec_helper'

describe 'workstation::k8s::docker_repos' do
  let(:title) { 'test repos' }
  let(:params) do
    {
      channel: 'test',
      enabled: true,
    }
  end

  it { is_expected.to compile.with_all_deps }

  it 'enables the main repo' do
    is_expected.to(
      contain_yumrepo('docker-ce-test')
        .with_ensure('present')
        .with_name('docker-ce-test')
        .with_descr('Docker CE Test - $basearch')
        .with_baseurl('https://download.docker.com/linux/centos/$releasever/$basearch/test')
        .with_enabled(1)
        .with_gpgcheck(1)
        .with_gpgkey('https://download.docker.com/linux/centos/gpg')
    )
  end

  it 'disables the main repo' do
    params[:enabled] = false
    is_expected.to(
      contain_yumrepo('docker-ce-test')
        .with_enabled(0)
    )
  end

  it 'disables debug and source repos' do
    is_expected.to(
      contain_yumrepo('docker-ce-test-debuginfo')
        .with_ensure('present')
        .with_name('docker-ce-test-debuginfo')
        .with_descr('Docker CE Test - Debuginfo $basearch')
        .with_baseurl('https://download.docker.com/linux/centos/$releasever/debug-$basearch/test')
        .with_enabled(0)
        .with_gpgcheck(1)
        .with_gpgkey('https://download.docker.com/linux/centos/gpg')
    )
    is_expected.to(
      contain_yumrepo('docker-ce-test-source')
        .with_ensure('present')
        .with_name('docker-ce-test-source')
        .with_descr('Docker CE Test - Sources')
        .with_baseurl('https://download.docker.com/linux/centos/$releasever/source/test')
        .with_enabled(0)
        .with_gpgcheck(1)
        .with_gpgkey('https://download.docker.com/linux/centos/gpg')
    )
  end

  it 'enables debug if told to' do
    params[:enable_debuginfo] = true
    is_expected.to(
      contain_yumrepo('docker-ce-test-debuginfo')
        .with_enabled(1)
    )
  end

  it 'enables source if told to' do
    params[:enable_source] = true
    is_expected.to(
      contain_yumrepo('docker-ce-test-source')
        .with_enabled(1)
    )
  end

  it 'does not enable debug or source if main is disabled' do
    params[:enabled] = false
    params[:enable_debuginfo] = true
    params[:enable_source] = true

    is_expected.to(
      contain_yumrepo('docker-ce-test')
        .with_enabled(0)
    )
    is_expected.to(
      contain_yumrepo('docker-ce-test-debuginfo')
        .with_enabled(0)
    )
    is_expected.to(
      contain_yumrepo('docker-ce-test-source')
        .with_enabled(0)
    )
  end
end
