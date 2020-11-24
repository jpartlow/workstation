require 'spec_helper'

describe 'workstation::copy_secret_and_link' do
  let(:title) { '/some/file' }
  let(:params) do
    {
      user: 'test',
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

  context 'when local file is missing' do
    let(:title) { '/not/present' }

    it 'fails' do
      is_expected.to compile.and_raise_error(/Could not find any files/)
    end

    it 'warns but does not fail it is told not to' do
      params[:fail_if_missing] = false
      is_expected.to compile
      expect(@logs.map(&:message)).to include(/Unable to find local file/)
    end
  end
end
