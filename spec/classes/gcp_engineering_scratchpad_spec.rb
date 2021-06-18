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

  it { is_expected.to contain_ini_setting('NetworkManager dns') }
  it { is_expected.to contain_service('NetworkManager') }
  it { is_expected.to contain_class('resolv_conf') }

  context 'debian' do
    let(:family) { 'Debian' }
  end
end
