require 'spec_helper'

describe 'workstation::profile::k8s' do
  let(:params) { {} }

  it { is_expected.to compile.with_all_deps }

  it 'installs docker' do
    is_expected.to contain_package('docker-ce')
  end

  it 'installs containerd' do
    params[:container_type] = 'containerd'
    is_expected.to contain_package('containerd.io')
  end
end
