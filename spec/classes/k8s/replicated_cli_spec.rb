require 'spec_helper'

describe 'workstation::k8s::replicated_cli' do
  it { is_expected.to compile.with_all_deps }
end
