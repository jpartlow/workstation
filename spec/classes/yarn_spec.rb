require 'spec_helper'

describe 'workstation::yarn' do
  let(:params) do
    {
      user: 'test',
    }
  end

  it { is_expected.to compile.with_all_deps }
end
