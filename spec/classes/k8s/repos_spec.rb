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
end
