require 'spec_helper'

describe 'workstation::k8s::kots' do
  it { is_expected.to compile.with_all_deps }
end
