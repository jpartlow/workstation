require 'spec_helper'

describe 'workstation::k8s::krew_plugin' do
  let(:title) { 'test' }
  let(:params) do
    { 
      user: 'centos'
    }
  end

  it { is_expected.to compile.with_all_deps }
  it 'can override plugin' do
    params[:plugin] = 'other'

    is_expected.to contain_exec('install-other-for-krew')
      .with_command('kubectl krew install other')
      .with_cwd('/home/centos')
  end
end
