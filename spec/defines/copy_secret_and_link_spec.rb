require 'spec_helper'

describe 'workstation::copy_secret_and_link' do
  let(:title) { 'test' }
  let(:params) do
    {
      user: 'test',
      local_file: '/some/file',
    }
  end

  include_context('fake files', { '/some/file' => 'stuff' })

  it { is_expected.to compile.with_all_deps }

  it 'links' do
    params[:links] = [
      '/link1',
      '/link2',
    ]

    is_expected.to contain_file('/link1')
      .with_ensure('link')
      .with_target('/home/test/file')
    is_expected.to contain_file('/link2')
      .with_ensure('link')
      .with_target('/home/test/file')
  end
end
