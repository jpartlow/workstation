require 'spec_helper'

describe 'workstation::k8s::kind' do
  it do
    is_expected.to compile.with_all_deps
  end
end
