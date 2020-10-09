require 'spec_helper'

describe 'workstation::k8s' do
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
end
