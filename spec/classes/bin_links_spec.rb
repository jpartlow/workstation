require 'spec_helper'

describe 'workstation::bin_links' do
  let(:params) do
    {
      :account  => 'bob',
      :packages => ['foo','bar'],
    }
  end

  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_file('/home/bob/bin/puppet')
      .with_target('/opt/puppetlabs/bin/puppet')
  end

  it { is_expected.to have_file_resource_count(3) }

  context 'with bolt' do
    let(:params) do
      {
        :account  => 'bob',
        :packages => ['foo','puppet-bolt'],
      }
    end

    it do
      is_expected.to contain_file('/home/bob/bin/bolt')
        .with_target('/opt/puppetlabs/bin/bolt')
    end

    it { is_expected.to have_file_resource_count(4) }
  end
end
