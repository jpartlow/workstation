require 'spec_helper'

describe 'workstation::gcp_engineering_scratchpad' do
  let(:family) { 'RedHat' }
  let(:facts) do
    {
      'os'       => {
        'family' => family,
      }
    }
  end

  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_ini_setting('NetworkManager dns')
      .with_path('/etc/NetworkManager/NetworkManager.conf')
      .with_section('main')
      .with_setting('dns')
      .with_value('none')
  end
  it { is_expected.to contain_service('NetworkManager') }
  it do
    is_expected.to contain_class('resolv_conf')
      .with_nameservers(['10.240.0.10'])
  end

  context 'debian' do
    let(:family) { 'Debian' }

    it do
      is_expected.to contain_ini_setting('Resolved.conf')
        .with_path('/etc/systemd/resolved.conf')
        .with_section('Resolve')
        .with_setting('DNS')
        .with_value('10.240.0.10')
    end
    it { is_expected.to contain_service('systemd.resolved') }
  end
end
