require 'spec_helper'

describe 'workstation::k8s::k9s' do
  it { is_expected.to compile.with_all_deps }
end
