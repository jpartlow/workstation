require 'spec_helper'

describe 'workstation::k8s::holodeck_testing' do
  let(:params) do
    {
      'dev_user' => 'test',
    }
  end

  it { is_expected.to compile.with_all_deps }
end
