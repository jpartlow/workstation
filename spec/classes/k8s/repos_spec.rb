require 'spec_helper'

describe 'workstation::k8s::repos' do
  let(:params) do
    {
      docker_channel: 'stable',
      enable_debuginfo_repo: false,
      enable_source_repo: false,
    }
  end

  it { is_expected.to compile.with_all_deps }

  it 'creates repos before cleaning the yum cache' do
    is_expected.to(
      contain_exec('yum-clean-all')
        .with_refreshonly(true)
        .that_subscribes_to(
          [
            'Yumrepo[extras]',
            'Yumrepo[kubernetes]',
            'Yumrepo[docker-ce-stable]'
          ]
        )
    )
  end

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

  context('test') do
    let(:params) do
      {
        docker_channel: 'test',
        enable_debuginfo_repo: false,
        enable_source_repo: false,
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
        docker_channel: 'stable',
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

  it 'cleans the yum cache if notified' do
    is_expected.to(contain_exec('yum-clean-all').with_refreshonly(true))
  end

  it 'enables kubernetes' do
    is_expected.to(
      contain_yumrepo('kubernetes')
        .with_baseurl('https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64')
        .with_enabled(1)
    )
  end

end
