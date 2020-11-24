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

  it 'copies' do
    is_expected.to contain_file('/home/test/file')
      .with_ensure('present')
      .with_mode('0600')
      .with_owner('test')
      .with_group('test')
      .with_content('stuff')
  end

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

  it 'copies to an explicit destination' do
    params[:destination] = '/some/where/else'
    is_expected.to contain_file('/some/where/else')
      .with_ensure('present')
      .with_content('stuff')
  end
end
