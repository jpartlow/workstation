require 'spec_helper'

describe 'workstation::k8s::krew' do
  let(:params) do
    {
      user: 'centos',
    }
  end

  it { is_expected.to compile.with_all_deps }

  it 'runs a single line install command' do
    is_expected.to(
      contain_exec('krew-install')
        .with(
          'command' => /\A[^\n]+install krew\Z/
        )
        .that_requires('Package[git]')
    )
  end
end
